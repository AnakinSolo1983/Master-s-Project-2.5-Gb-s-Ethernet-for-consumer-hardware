#!/bin/bash -x

RSF=${1}
NUM=${2}
FLG=${3}

RSF=result/xdp2/pcap/run${RSF}
PCAP=rules_${NUM}.pcap

# Remove all files in it:
rm -rf ${RSF}/*

# Create dir, if it doesn't exist yet:
mkdir -p ${RSF}

if [ "$NUM" == "1" ]; then
	TRC='../1_mod_rule_trace'
elif [ "$NUM" == "2" ]; then
	TRC='../2_mod_rule_trace'
elif [ "$NUM" == "3" ]; then
	TRC='../3_mod_rule_trace'
elif [ "$NUM" == "5k" ]; then
	TRC='../5k_mod_rule_trace'
elif [ "$NUM" == "10k" ]; then
	TRC='../10k_mod_rule_trace'
fi

# Save NUM to text file for later use:
echo $NUM > num.txt

# Move to directory dpdk-acl-bpf:
cd dpdk-acl-bpf

# Check that we are in directory dpdk-acl-bpf:
pwd

# Load the xdp program:
ip netns exec ns1 xdp-loader load -vv enp87s0 app/acl-bpf/xdp_acl4.o

# Get the status:
sudo ip netns exec ns1 xdp-loader status -vv

# Get the information on the bpf maps:
sudo ip netns exec ns1 bpftool map show >> ../${RSF}/bpfstat.out 2>&1

# Get the id numbers for the two maps:
acl_ctx_id=$(sudo ip netns exec ns1 bpftool map show | grep acl_ctx | cut -d':' -f1 | tr -d ' ')
acl_trans_id=$(sudo ip netns exec ns1 bpftool map show | grep acl_trans | cut -d':' -f1 | tr -d ' ')
acl_rule_id=$(sudo ip netns exec ns1 bpftool map show | grep acl_rule | cut -d':' -f1 | tr -d ' ')

ip netns exec ns1 stdbuf -o0 -e0 ./x86_64-default-linuxapp-gcc-dbg/app/dpdk-acl-bpf -n 1 --lcores='1' --no-pci --no-huge --log-level "debug" -- --rulesf=../${NUM}_mod_rule --tracef=${TRC} --iter=1 --verbose=3 --rulenum=100000 --tracenum=100000  --bpf=${acl_ctx_id}:${acl_trans_id}:${acl_rule_id}

ip netns exec ns1 bpftool map lookup name acl_rule key 1 0 0 0

# Leave the directory:
cd ..

# Check that we left;
pwd

# irqs:
/bin/bash -x tpc_irq.sh ${RSF} 20 ${NUM} ${PCAP}

# Move back to directory dpdk-acl-bpf:
cd dpdk-acl-bpf

# Check that we are in directory dpdk-acl-bpf:
pwd

ip netns exec ns1 bpftool map lookup name acl_rule key 1 0 0 0

# Unload the program:
ip netns exec ns1 xdp-loader unload -a enp87s0 -vv

