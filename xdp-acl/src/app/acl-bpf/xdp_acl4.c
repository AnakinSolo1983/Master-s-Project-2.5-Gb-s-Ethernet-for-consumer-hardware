#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <linux/if_ether.h>
#include <arpa/inet.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <linux/udp.h>
#include <linux/tcp.h>

#include <limits.h>
#include <stdint.h>
#include "acl_bpf.h"
#include "acl_internal.h"
#include "acl_xdp.h"

/*
 * to perform packet filtering XDP-ACL needs 3 MAPs fille by user-space:
 * acl_ctx - contains some data about generated ACL conext
 * acl_trans - contains actual 'transitions' array, i.e. generated and
 * compressed trie representation.
 * acl_rule - contains actual rules to match.
 */
struct {
        __uint(type, BPF_MAP_TYPE_ARRAY);
        __type(key, uint32_t);
        __type(value, struct rte_acl_bpf_ctx);
        __uint(max_entries, 1);
} acl_ctx SEC(".maps");

struct {
        __uint(type, BPF_MAP_TYPE_ARRAY);
        __type(key, uint32_t);
        __type(value, uint64_t);
        __uint(max_entries, 0x400000);
} acl_trans SEC(".maps");

struct {
        __uint(type, BPF_MAP_TYPE_ARRAY);
        __type(key, uint32_t);
        __type(value, struct ipv4_rule);
        __uint(max_entries, 0x10000);
} acl_rule SEC(".maps");


union packet_data {
	struct ipv4_5tuple data;
	uint8_t raw[sizeof(struct ipv4_5tuple)];
};

#define DIM(a)	(sizeof(a) / sizeof(a[0]))

/*
 * Here we perform search through transitions array, exactly in the same
 * way it is done by lib/acl/acl_run_scalar.c, except that we always
 * search one packet at a time.
 * As a rule of thumb:
 * - if match is found, it returns XDP_DROP
 * - else if we realize that no match for given packet exists,
 *   it returns XDP_PASS
 * - else return XDP_ABORT, which means that the search shall continue to
 *   the next level of the trie.
 */
static enum xdp_action
resolve_match(uint32_t match_index, uint64_t trans)
{
	uint32_t idx;
	union rte_acl_bpf_match *match;
	struct ipv4_rule *rule;

	trans &= RTE_ACL_NODE_INDEX;
	idx = match_index + trans;

	/* get match record */
	match = bpf_map_lookup_elem(&acl_trans, &idx);
	if (match == NULL) {
		return XDP_PASS;
	}

	/* find corresponding rule record */
	idx = match->result;
	//bpf_printk("%s:%d *idx=%u\n", __func__, __LINE__, idx);
	rule = bpf_map_lookup_elem(&acl_rule, &idx);
	if (rule == NULL)
		return XDP_PASS;

	/* update rule stats */
	__atomic_fetch_add(&rule->num_packet, 1, __ATOMIC_RELAXED);

	return rule->action;
}

static inline uint32_t
scan_forward(uint32_t input, uint32_t max)
{
	return (input == 0) ? max : __builtin_ctz(input);
}

static uint32_t
resolve_next_index(uint64_t transition, uint8_t input)
{
	uint32_t addr, index, ranges, x, a, b, c;

	/* break transition into component parts */
	ranges = transition >> (sizeof(index) * CHAR_BIT);
	index = transition & ~RTE_ACL_NODE_INDEX;
	addr = transition ^ index;

	if (index != RTE_ACL_NODE_DFA) {
		/* calc address for a QRANGE/SINGLE node */
		c = (uint32_t)input * SCALAR_QRANGE_MULT;
		a = ranges | SCALAR_QRANGE_MIN;
		a -= (c & SCALAR_QRANGE_MASK);
		b = c & SCALAR_QRANGE_MIN;
		a &= SCALAR_QRANGE_MIN;
		a ^= (ranges ^ b) & (a ^ b);
		x = scan_forward(a, 32) >> 3;
	} else {
		/* calc address for a DFA node */
		x = ranges >> (input /
			RTE_ACL_DFA_GR64_SIZE * RTE_ACL_DFA_GR64_BIT);
		x &= UINT8_MAX;
		x = input - x;
	}

	addr += x;
	return addr;
}

static inline int
one_step_trans(uint32_t match_index, uint8_t input, uint64_t trans,
	uint64_t *next) 
{
	uint32_t idx;
	enum xdp_action action;
	const uint64_t *val;

	idx = resolve_next_index(trans, input);
	val = bpf_map_lookup_elem(&acl_trans, &idx);
	if (val == NULL)
		return XDP_PASS;
	trans = *val;
	/* if match is found */
	if ((trans & RTE_ACL_NODE_MATCH) != 0) {
		action = resolve_match(match_index, trans);
		//bpf_printk("%s:%d *action=%d\n", __func__, __LINE__, action);
		return action;
	}
	*next = trans;
	return XDP_ABORTED;
}


SEC("xdp_prog")
int xdp_acl_prog1(struct xdp_md *ctx)
{
	void *data_end;
	void *data;
	int32_t rc;
	enum xdp_action action;
	uint32_t i, idx, input, iphlen, match_index, ofs;
	uint64_t trans;
	const uint64_t *val;
	struct ethhdr *eth;
	struct iphdr *iph;
	struct udphdr *udph;
	union packet_data pd;
	const struct rte_acl_bpf_ctx *bcx;

	data_end = (void *)(long)ctx->data_end;
	data = (void *)(long)ctx->data;

	eth = data;
	if (data + sizeof(*eth) > data_end)
        	return XDP_DROP;

	if (eth->h_proto != htons(ETH_P_IP))
		return XDP_PASS;

	iph = (struct iphdr *)(eth + 1);
	if ((void *)(iph + 1) > data_end)
		return XDP_DROP;

	pd.data.proto = iph->protocol;
	pd.data.ip_src = iph->saddr;
	pd.data.ip_dst = iph->daddr;

	iphlen = iph->ihl * sizeof(uint32_t);
	udph = (struct udphdr *)((uint8_t *)iph + iphlen);

	if((void *)(udph + 1) > data_end)
		return XDP_PASS;

	pd.data.port_src = udph->source;
	pd.data.port_dst = udph->dest;

	/* start search with IP proto */
	i = 0;
	bcx = bpf_map_lookup_elem(&acl_ctx, &i);
	if (bcx == NULL)
		return XDP_PASS;

	match_index = bcx->match_index;

	input = pd.data.proto;
	idx = bcx->trie[0].root_index + input;
	val = bpf_map_lookup_elem(&acl_trans, &idx);
	if (val == NULL)
		return XDP_PASS;
	trans = *val;
	/* if match is found */
	if ((trans & RTE_ACL_NODE_MATCH) != 0) {
		action = resolve_match(match_index, trans);
		return action;
	}

	/* continue search with IP src addr */
	ofs = offsetof(struct ipv4_5tuple, ip_src);
	rc = one_step_trans(match_index, pd.raw[ofs], trans, &trans); 
	if (rc != XDP_ABORTED)
		return rc;

	rc = one_step_trans(match_index, pd.raw[ofs + 1], trans, &trans); 
	if (rc != XDP_ABORTED)
		return rc;

	rc = one_step_trans(match_index, pd.raw[ofs + 2], trans, &trans); 
	if (rc != XDP_ABORTED)
		return rc;

	rc = one_step_trans(match_index, pd.raw[ofs + 3], trans, &trans); 
	if (rc != XDP_ABORTED)
		return rc;

	/* continue search with IP dest addr */
	ofs = offsetof(struct ipv4_5tuple, ip_dst);
	rc = one_step_trans(match_index, pd.raw[ofs], trans, &trans); 
	if (rc != XDP_ABORTED)
		return rc;

	rc = one_step_trans(match_index, pd.raw[ofs + 1], trans, &trans); 
	if (rc != XDP_ABORTED)
		return rc;

	rc = one_step_trans(match_index, pd.raw[ofs + 2], trans, &trans); 
	if (rc != XDP_ABORTED)
		return rc;

	rc = one_step_trans(match_index, pd.raw[ofs + 3], trans, &trans); 
	if (rc != XDP_ABORTED)
		return rc;

	/* continue search with L4 src port number */
	ofs = offsetof(struct ipv4_5tuple, port_src);
	rc = one_step_trans(match_index, pd.raw[ofs], trans, &trans); 
	if (rc != XDP_ABORTED)
		return rc;

	rc = one_step_trans(match_index, pd.raw[ofs + 1], trans, &trans); 
	if (rc != XDP_ABORTED)
		return rc;

	/* continue search with L4 dest port number */
	ofs = offsetof(struct ipv4_5tuple, port_dst);
	rc = one_step_trans(match_index, pd.raw[ofs], trans, &trans); 
	if (rc != XDP_ABORTED)
		return rc;

	rc = one_step_trans(match_index, pd.raw[ofs + 1], trans, &trans); 
	if (rc != XDP_ABORTED)
		return rc;
	
	return XDP_PASS;
}

char _license[] SEC("license") = "GPL";
