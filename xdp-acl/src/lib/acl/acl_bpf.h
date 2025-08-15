/* SPDX-License-Identifier: BSD-3-Clause
 * Copyright(c) 2010-2014 Intel Corporation
 */

#ifndef _ACL_BPF_H_
#define _ACL_BPF_H_

/** MAX number of tries per one ACL BPF context.*/
#define RTE_ACL_BPF_MAX_TRIES	8

/** MAX bytes to classify for BPF */
#define RTE_ACL_BPF_MAX_DATA_LEN	40

struct rte_acl_bpf_trie {
	uint32_t root_index;
	uint32_t num_offset;
	uint32_t data_offset[RTE_ACL_BPF_MAX_DATA_LEN];
};

struct rte_acl_bpf_ctx {
	uint32_t num_trans;
	uint32_t match_index;
	uint32_t num_matches;
	uint32_t num_tries;
	struct rte_acl_bpf_trie trie[RTE_ACL_BPF_MAX_TRIES];
};

union rte_acl_bpf_match {
	uint64_t raw;
	struct {
		uint32_t result;
		int32_t priority;
	};
};

#endif /* _ACL_BPF_H_ */
