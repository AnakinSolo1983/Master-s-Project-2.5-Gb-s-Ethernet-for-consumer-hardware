#!/bin/bash -x

RSF=${1}
NUM=${2}
FLG=${3}

RSF=acl_rl/run${RSF}
PTH=''
TRC=''

# Remove all files in it:
rm -rf ${RSF}/*

# Create dir, if it doesn't exist yet:
mkdir -p ${RSF}

#Changes
# Creating trace files for the first three sets of rules:
#classbench-tr/classbench-ng/trace_generator/trace_generator 1 0 10000 1_mod_rule #classbench-ng/rules.1
#wc -l *_trace

#classbench-tr/classbench-ng/trace_generator/trace_generator 1 0 1000 2_mod_rule
#classbench-ng/rules.2
#wc -l rules*2*
#wc -l classbench-ng/rules.2*

#classbench-tr/classbench-ng/trace_generator/trace_generator 1 0 190 3_mod_rule #classbench-ng/rules.3
#wc -l rules.3*
#Changes

if [ "$NUM" == "1" ]; then
	PTH='classbench-ng/rules.1'
	python3 pnew.py ${PTH} ${NUM}
	TRC='../1_mod_rule_trace'
elif [ "$NUM" == "2" ]; then
	PTH='classbench-ng/rules.2'
	python3 pnew.py ${PTH} ${NUM}
	TRC='../2_mod_rule_trace'
elif [ "$NUM" == "3" ]; then
	PTH='classbench-ng/rules.3'
	python3 pnew.py ${PTH} ${NUM}
	TRC='../3_mod_rule_trace'
elif [ "$NUM" == "10k" ]; then
	PTH='dts/dep/test-acl-input/acl1v4_10k_rule'
	python3 pnew.py ${PTH} ${NUM}
	#TRC='../dts/dep/test-acl-input/acl1v4_10k_trace'
	TRC='../10k_mod_rule_trace'
fi

# Save NUM to text file for later use:
echo $NUM > num.txt

# Modify the rules:
#python3 pnew.py ${PTH}

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

#ip netns exec ns1 stdbuf -o0 -e0 ./x86_64-default-linuxapp-gcc13-dbg/app/dpdk-test-acl -n 1 --lcores='1' --no-pci --no-huge --log-level "debug" -- --rulesf=../10k_mod_rule --tracestep=1 --iter=1 --verbose=0 --rulenum=100000 --bpf=${acl_ctx_id}:${acl_trans_id}
#OUT=../${OUT}
#ip netns exec ns1 stdbuf -o0 -e0 ./x86_64-default-linuxapp-gcc13-dbg/app/dpdk-test-acl -n 1 --lcores='1' --no-pci --no-huge --log-level "debug" -- --rulesf=../${NUM}_mod_rule --tracef=${TRC} --tracestep=1 --iter=1 --verbose=0 --rulenum=100000 --bpf=${acl_ctx_id}:${acl_trans_id}

#ip netns exec ns1 stdbuf -o0 -e0 ./x86_64-default-linuxapp-gcc13-dbg/app/dpdk-test-acl -n 1 --lcores='1' --no-pci --no-huge --log-level "debug" -- --rulesf=../dts/dep/test-acl-input/acl1v4_10k_rule --tracef=../dts/dep/test-acl-input/acl1v4_10k_trace --tracestep=1 --iter=1 --verbose=0 --rulenum=100000 --bpf=${acl_ctx_id}:${acl_trans_id}

ip netns exec ns1 stdbuf -o0 -e0 ./x86_64-default-linuxapp-gcc-dbg/app/dpdk-acl-bpf -n 1 --lcores='1' --no-pci --no-huge --log-level "debug" -- --rulesf=../${NUM}_mod_rule --tracef=${TRC} --iter=1 --verbose=3 --rulenum=100000 --tracenum=100000  --bpf=${acl_ctx_id}:${acl_trans_id}:${acl_rule_id}

ip netns exec ns1 bpftool map lookup name acl_rule key 1 0 0 0

# Leave the directory:
cd ..

# Check that we left;
pwd

# irqs:
#/bin/bash -x testpirq1.sh ${RSF} 20 ${NUM}
/bin/bash -x test4_2.sh ${RSF} 20

# Move back to directory dpdk-acl-bpf:
cd dpdk-acl-bpf

# Check that we are in directory dpdk-acl-bpf:
pwd

#ip netns exec ns1 tcpdump -i enp87s0 &
#TCP=$!
ip netns exec ns1 bpftool map lookup name acl_rule key 1 0 0 0

# Unload the program:
ip netns exec ns1 xdp-loader unload -a enp87s0 -vv

#kill ${TCP}

