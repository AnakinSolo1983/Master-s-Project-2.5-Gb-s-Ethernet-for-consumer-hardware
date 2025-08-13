#!/bin/bash -x

#----------

# This Bash script manages Access Control List (ACL) rules, loads an XDP program, and retrieving information on BPF maps using modified rules the trace file for these rules.

#----------

RSF=${1} # Path where the results will be stored.
NUM=${2} # Number for the specific set of rules.

RSF=result/xdp2/wrk/run${RSF}
TRC='' # The trace file.

# Remove all files in it:
rm -rf ${RSF}/*

# Create dir, if it doesn't exist yet:
mkdir -p ${RSF}

# For which set of rules trace file must be used:
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

# Lookup the BPF map for ACL rules.
ip netns exec ns1 bpftool map lookup name acl_rule key 1 0 0 0

# Leave the directory:
cd ..

# Check that we left;
pwd

# irqs:
/bin/bash -x test_irq.sh ${RSF} 20

# Move back to directory dpdk-acl-bpf:
cd dpdk-acl-bpf

# Check that we are in directory dpdk-acl-bpf:
pwd

ip netns exec ns1 bpftool map lookup name acl_rule key 1 0 0 0

# Unload the program:
ip netns exec ns1 xdp-loader unload -a enp87s0 -vv

