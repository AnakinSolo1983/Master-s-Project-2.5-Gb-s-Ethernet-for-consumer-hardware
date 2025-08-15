
#ifndef _ACL_XDP_H_
#define _ACL_XDP_H_

/**
 * Define common structures that are used both by user-space and XDP programs.
 */

/**
 * IPv4 header fields we are searching through:
 * - IP protocol value (8 bits)
 * - IP source address (32 bits)
 * - IP destination address (32 bits)
 * - L4 protocol (UDP/TCP) source port number (16 bits)
 * - L4 protocol (UDP/TCP) destination port number (16 bits)
 */
struct ipv4_5tuple {
        uint8_t  proto;
        uint32_t ip_src;
        uint32_t ip_dst;
        uint16_t port_src;
        uint16_t port_dst;
};

struct ipv4_5tuple_rule {
	uint8_t proto;                 /**< IPv4 protocol ID. */
	uint8_t proto_mask;            /**< IPv4 protocol ID mask. */
	uint32_t ip_src;               /**< IPv4 source address. */
	uint32_t ip_src_mask_len;      /**< length of source address mask. */
	uint32_t ip_dst;               /**< IPv4 dest address. */
	uint32_t ip_dst_mask_len;      /**< length of dest address mask. */
	uint16_t port_src_low;         /**< L4 source port low. */
        uint16_t port_src_high;        /**< L4 source port high. */
        uint16_t port_dst_low;         /**< L4 destination port low. */
        uint16_t port_dst_high;        /**< L4 destination port high. */
};

struct ipv4_rule {
	uint32_t id;
	enum xdp_action action;
	struct ipv4_5tuple_rule rule;
	uint64_t num_packet;
};

/**
 * IPv6 header fields we are searching through:
 * - IP protocol value (8 bits)
 * - IP source address (128 bits)
 * - IP destination address (128 bits)
 * - L4 protocol (UDP/TCP) source port number (16 bits)
 * - L4 protocol (UDP/TCP) destination port number (16 bits)
 */

#define IPV6_ADDR_LEN   16
#define IPV6_ADDR_U16   (IPV6_ADDR_LEN / sizeof(uint16_t))
#define IPV6_ADDR_U32   (IPV6_ADDR_LEN / sizeof(uint32_t))
#define IPV6_ADDR_U64   (IPV6_ADDR_LEN / sizeof(uint64_t))

struct ipv6_5tuple {
	uint8_t  proto;
	uint32_t ip_src[IPV6_ADDR_U32];
	uint32_t ip_dst[IPV6_ADDR_U32];
	uint16_t port_src;
	uint16_t port_dst;
};

#endif /* _ACL_XDP_H_ */
