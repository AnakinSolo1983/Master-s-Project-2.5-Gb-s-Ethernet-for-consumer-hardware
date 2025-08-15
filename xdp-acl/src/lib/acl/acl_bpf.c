/* SPDX-License-Identifier: BSD-3-Clause
 * Copyright(c) 2010-2014 Intel Corporation
 */

#include <rte_acl.h>
#include "acl.h"
#include "acl_log.h"
#include "acl_run.h"
#include "acl_bpf.h"

#include <bpf/bpf.h>
#include <unistd.h>

static void
acl_bpf_reset(struct rte_acl_bpf_fd *btx)
{
	btx->trans_fd = -1;
	btx->ctx_fd = -1;
	btx->rule_fd = -1;
}

static void
fill_bpf_ctx(struct rte_acl_bpf_ctx *btx, const struct rte_acl_ctx *ctx)
{
	uint32_t i, j, k, n;

	memset(btx, 0, sizeof(*btx));

	n = ctx->match_index + ctx->num_rules + 1;
	btx->num_trans = n;
	btx->match_index = ctx->match_index;
	btx->num_matches = ctx->num_rules + 1;

	/* copy tries */
	btx->num_tries = ctx->num_tries;
	for (i = 0; i != btx->num_tries; i++) {
		btx->trie[i].root_index = ctx->trie[i].root_index;
		n = 4 * (ctx->trie[i].num_data_indexes - 1) + 1;
		btx->trie[i].num_offset = n;
		btx->trie[i].data_offset[0] = ctx->trie[i].data_index[0];
		for (j = 1; j != ctx->trie[i].num_data_indexes; j++) {
			k = 4 * (j - 1) + 1;
			n = ctx->trie[i].data_index[j];
			btx->trie[i].data_offset[k] = n;
			btx->trie[i].data_offset[k + 1] = n + 1;
			btx->trie[i].data_offset[k + 2] = n + 2;
			btx->trie[i].data_offset[k + 3] = n + 3;
		}
	}
}

static int
fill_ctx_map(const struct rte_acl_bpf_fd *bpx,  const struct rte_acl_ctx *ctx)
{
	int32_t rc;
	uint32_t i;
	struct rte_acl_bpf_ctx btx;

	fill_bpf_ctx(&btx, ctx);

	i = 0;
	rc = bpf_map_update_elem(bpx->ctx_fd, &i, &btx, BPF_ANY);
	if (rc != 0)
		printf("%s:%d  "
			"bpf_map_update_elem(fd=%d, key=%u, val=%p"
			" failed, rc=%d, errno=%d\n",
			__func__, __LINE__,
			bpx->ctx_fd, i, &btx, rc, errno);
	return rc;
}

static int
fill_trans_map(const struct rte_acl_bpf_fd *bpx,  const struct rte_acl_ctx *ctx)
{
	int32_t rc;
	uint32_t i, j, k;
	struct rte_acl_bpf_ctx btx;
	union rte_acl_bpf_match bpf_match;
	const struct rte_acl_match_results *match;

	fill_bpf_ctx(&btx, ctx);

	rc = 0;
	for (i = 0; i != btx.match_index && rc == 0; i++) {
		rc = bpf_map_update_elem(bpx->trans_fd, &i,
				ctx->trans_table + i, BPF_ANY);
	}

	match = ((const struct rte_acl_match_results *)(ctx->trans_table + i));
	for(j = 0; j != btx.num_matches && rc == 0; j++) {
		k = i + j;
		bpf_match.result = match[j].results[0];
		bpf_match.priority = match[j].priority[0];
		rc = bpf_map_update_elem(bpx->trans_fd, &k, &bpf_match.raw,
			BPF_ANY);
	}

	if (rc != 0)
		printf("%s:%d  "
			"bpf_map_update_elem(fd=%d, key=%u, val=%" PRIx64
			" failed, rc=%d, errno=%d\n",
			__func__, __LINE__,
			bpx->trans_fd, i, ctx->trans_table[i],
			rc, errno);

	return rc;
}

int
rte_acl_bpf_open(const struct rte_acl_bpf_id *bpid, struct rte_acl_bpf_fd *bpfd)
{
	int32_t rc;

	/* set all file descriptors to -1 */
	acl_bpf_reset(bpfd);

	bpfd->ctx_fd = bpf_map_get_fd_by_id(bpid->ctx_id);
	rc = (bpfd->ctx_fd < 0) ? -errno : 0;
	printf("%s:%d  "
		"bpf_map_get_fd(=\"%u\") returns %d, errno=%d\n",
		__func__, __LINE__, bpid->ctx_id,  bpfd->ctx_fd, rc);

	if (rc == 0) {
		bpfd->trans_fd = bpf_map_get_fd_by_id(bpid->trans_id);
		rc = (bpfd->trans_fd < 0) ? -errno : 0;
		printf("%s:%d  "
			"bpf_map_get_fd(=\"%u\") returns %d, errno=%d\n",
			__func__, __LINE__,
			bpid->trans_id,  bpfd->trans_fd, rc);
	}

	if (rc == 0) {
		bpfd->rule_fd = bpf_map_get_fd_by_id(bpid->rule_id);
		rc = (bpfd->rule_fd < 0) ? -errno : 0;
		printf("%s:%d  "
			"bpf_map_get_fd(=\"%u\") returns %d, errno=%d\n",
			__func__, __LINE__,
			bpid->rule_id,  bpfd->rule_fd, rc);
	}

	/* success */
	if (rc == 0)
		return 0;

	rte_acl_bpf_close(bpfd);
	return rc;
}

int
rte_acl_bpf_fill(const struct rte_acl_bpf_fd *bpfd,
	const struct rte_acl_ctx *ctx)
{
	int32_t rc;

	if (ctx->num_tries > 1)
		printf("%s:%d: !!! WARNING given ACL CTX uses %u tries, "
			"curret ACL XDP program supports only CTX with "
			"single trie - BPF matches might be invalid\n",
			__func__, __LINE__, ctx->num_tries);


	rc = fill_ctx_map(bpfd, ctx);

	if (rc == 0)
		rc = fill_trans_map(bpfd, ctx);

	return rc;
}

void
rte_acl_bpf_close(struct rte_acl_bpf_fd *bpx)
{
	close(bpx->trans_fd);
	close(bpx->ctx_fd);
	close(bpx->rule_fd);
	acl_bpf_reset(bpx);
}

static int
resolve_match(int32_t fd, uint32_t match_index, uint64_t trans,
	 union rte_acl_bpf_match *match)
{
	int32_t rc;
	uint32_t idx;

	trans &= RTE_ACL_NODE_INDEX;
	idx = match_index + trans;

	/* get match record */
	rc = bpf_map_lookup_elem(fd, &idx, match);
	if (rc != 0) {
		printf("%s:%d  "
			"bpf_map_lokup_elem(fd=%d, key=%u) failed, "
			" rc=%d, errno=%d\n",
			__func__, __LINE__, fd, idx, rc, errno);
		return rc;
	}

	return 0;
}

static inline uint32_t
scan_forward(uint32_t input, uint32_t max)
{
	return (input == 0) ? max : rte_bsf32(input);
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

static int
acl_trie_search(const struct rte_acl_bpf_ctx *btx, uint32_t trie_idx,
	int32_t trans_fd, const uint8_t *data, uint32_t data_len,
	union rte_acl_bpf_match *match)
{
	int32_t rc;
	uint32_t data_ofs, i, idx;
	uint64_t trans;
	uint8_t input;

	if (btx->trie[trie_idx].data_offset[0] >= data_len)
		return -ERANGE;

	i = 0;
	data_ofs = btx->trie[trie_idx].data_offset[i];
	input = data[data_ofs];
	idx = btx->trie[trie_idx].root_index + input;

	do {

		/* get next transision */
		rc = bpf_map_lookup_elem(trans_fd, &idx, &trans);
		if (rc != 0)
			break;

		/* if match is found */
		if ((trans & RTE_ACL_NODE_MATCH) != 0) {
			rc = resolve_match(trans_fd, btx->match_index,
				trans, match);
			break;
		}

		/* read next data offset */
		if (++i == btx->trie[trie_idx].num_offset)
			break;

		/* get next input byte */
		data_ofs = btx->trie[trie_idx].data_offset[i];
		if (data_ofs >= data_len) {
			rc = -ERANGE;
			break;
		/* get next trans based on input */
		} else {
			input = data[data_ofs];
			idx = resolve_next_index(trans, input);
		}
	} while (true);

	if (rc != 0) {
		printf("%s:%d  ERROR at transition lookup: "
			"data_index=%u, data_offset=%u, data_value=%#hhx: "
			"trans_fd=%d, key=%u failed, "
			" rc=%d, errno=%d\n",
			__func__, __LINE__,
			i, data_ofs, input,
			trans_fd, idx,
			rc, errno);
		return rc;
	} else if (i == btx->trie[trie_idx].num_offset) {
		printf("%s:%d(trans_fd=%d, data=%p, offset_idx=%u: "
			"!!! NO MATCH WAS FOUND !!!",
			__func__, __LINE__,  trans_fd, data, i);
		return -EINVAL;
	}

	return 0;
}

int
rte_acl_bpf_classify(const struct rte_acl_bpf_fd *bpx, const uint8_t *data,
	uint32_t data_len, uint32_t *res)
{
	int32_t rc;
	uint32_t i;
	struct rte_acl_bpf_ctx btx;
	union rte_acl_bpf_match cur, match;

	if (bpx == NULL || data == NULL || data_len == 0 || res == 0)
		return -EINVAL;

	/* read CTX record */
	i = 0;
	rc = bpf_map_lookup_elem(bpx->ctx_fd, &i, &btx);
	if (rc != 0) {
		printf("%s:%d  "
			"bpf_map_lokup_elem(fd=%d, key=%u) failed, "
			" rc=%d, errno=%d\n",
			__func__, __LINE__, bpx->ctx_fd, i, rc, errno);
		return rc;
	}

	cur.priority = INT32_MIN;
	cur.result = 0;
	for (i = 0; i != btx.num_tries; i++) {
		rc = acl_trie_search(&btx, i, bpx->trans_fd, data, data_len,
			&match);
		if (rc != 0)
			return rc;	
		/* if we found a match with greater priority, then use it */
		if (match.priority >= cur.priority)
			cur = match;
	}

	*res = cur.result;
	return rc;
}

