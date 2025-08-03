#!/bin/bash -x

NUM=$(cat num.txt)

# Creating trace files for the first three sets of rules:
classbench-tr/classbench-ng/trace_generator/trace_generator 1 0 10000 1_mod_rule #classbench-ng/rules.1
#wc -l *_trace

classbench-tr/classbench-ng/trace_generator/trace_generator 1 0 1000 2_mod_rule
#classbench-ng/rules.2
#wc -l rules*2*
#wc -l classbench-ng/rules.2*

classbench-tr/classbench-ng/trace_generator/trace_generator 1 0 190 3_mod_rule #classbench-ng/rules.3
#wc -l rules.3*
wc -l *_trace
# 200
cd dpdk-acl-bpf
pwd

# Converting classbench trace to pcap:
#time python3 ../mk_pcap_in_u5.py ../classbench-ng/rules.1_trace rules_t1.pcap 10:70:fd:30:43:c9 94:6d:ae:2e:79:f3 64

#time python3 ../mk_pcap_in_u5.py ../classbench-ng/rules.2_trace rules_t2.pcap 10:70:fd:30:43:c9 94:6d:ae:2e:79:f3 64

#time python3 ../mk_pcap_in_u5.py ../classbench-ng/rules.3_trace rules_t3.pcap 10:70:fd:30:43:c9 94:6d:ae:2e:79:f3 64

time python3 ../mk_pcap_in_u5.py ../1_mod_rule_trace  rules_t1.pcap 10:70:fd:30:43:c9 94:6d:ae:2e:79:f3 64

time python3 ../mk_pcap_in_u5.py ../2_mod_rule_trace  rules_t2.pcap 10:70:fd:30:43:c9 94:6d:ae:2e:79:f3 64

time python3 ../mk_pcap_in_u5.py ../3_mod_rule_trace  rules_t3.pcap 10:70:fd:30:43:c9 94:6d:ae:2e:79:f3 64

time python3 ../mk_pcap_in_u5.py ../dts/dep/test-acl-input/acl1v4_10k_trace acl1v4_10k_trace_u1.pcap 10:70:fd:30:43:c9 94:6d:ae:2e:79:f3 64


ip netns exec ns2 scapy
# All this can be done only in scapy:

if [ "NUM" == "1"]; then
	a=rdpcap("rules_t1.pcap")
	sendp(a, iface="enp88s0")
elif [ "$NUM" == "2" ]; then
	a=rdpcap("rules_t2.pcap")
	sendp(a, iface="enp88s0")
elif [ "$NUM" == "3" ]; then
	a=rdpcap("rules_t3.pcap")
	sendp(a, iface="enp88s0")
elif [ "$NUM" == "10k" ]; then
	a=rdpcap("acl1v4_10k_trace_u1.pcap")
	sendp(a, iface="enp88s0")
fi

# With xdp prog loaded and rules populated we shouldn't see any of these packets passing through.
ip netns exec ns1 tcpdump -i enp87s0 &
TCP=$!
ip netns exec ns2 ping -c 10 192.168.11.1
#ip netns exec ns2 wget 192.168.22.1:6000
kill ${TCP}












