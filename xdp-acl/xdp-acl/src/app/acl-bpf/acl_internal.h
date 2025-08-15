
#ifndef _ACL_INTERNAL_H_
#define _ACL_INTERNAL_H_

/*
 * !!! copy of internal defines from ACL library
 * we need it here to implement exactly the same classify() method
 * within our XDP program.
 */

/** Mask value of type "tp" for the first "ln" bit set. */
#define RTE_LEN2MASK(ln, tp)    \
	((tp)((uint64_t)-1 >> (sizeof(uint64_t) * CHAR_BIT - (ln))))

enum {
        RTE_ACL_TYPE_SHIFT = 29,
        RTE_ACL_MAX_INDEX = RTE_LEN2MASK(RTE_ACL_TYPE_SHIFT, uint32_t),
        RTE_ACL_MAX_PRIORITY = RTE_ACL_MAX_INDEX,
        RTE_ACL_MIN_PRIORITY = 1,
};

#define RTE_ACL_NODE_DFA	(0 << RTE_ACL_TYPE_SHIFT)
#define RTE_ACL_NODE_SINGLE	(1U << RTE_ACL_TYPE_SHIFT)
#define RTE_ACL_NODE_QRANGE	(3U << RTE_ACL_TYPE_SHIFT)
#define RTE_ACL_NODE_MATCH	(4U << RTE_ACL_TYPE_SHIFT)
#define RTE_ACL_NODE_TYPE	(7U << RTE_ACL_TYPE_SHIFT)
#define RTE_ACL_NODE_UNDEFINED	UINT32_MAX

#define RTE_ACL_QUAD_MAX	5
#define RTE_ACL_QUAD_SIZE	4
#define RTE_ACL_QUAD_SINGLE	UINT64_C(0x7f7f7f7f00000000)

#define RTE_ACL_SINGLE_TRIE_SIZE	2000

#define RTE_ACL_DFA_MAX		UINT8_MAX
#define RTE_ACL_DFA_SIZE	(UINT8_MAX + 1)

#define RTE_ACL_DFA_GR64_SIZE	64
#define RTE_ACL_DFA_GR64_NUM	(RTE_ACL_DFA_SIZE / RTE_ACL_DFA_GR64_SIZE)
#define RTE_ACL_DFA_GR64_BIT	\
	(CHAR_BIT * sizeof(uint32_t) / RTE_ACL_DFA_GR64_NUM)

#define RTE_ACL_NODE_INDEX	((uint32_t)~RTE_ACL_NODE_TYPE)

#define SCALAR_QRANGE_MULT	0x01010101
#define SCALAR_QRANGE_MASK	0x7f7f7f7f
#define SCALAR_QRANGE_MIN	0x80808080

#endif /* _ACL_INTERNAL_H_ */
