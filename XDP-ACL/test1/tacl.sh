#!/bin/bash -x

RSF=${1}
NUM=${2}

RSF=acl_r/run${RSF}
PTH=''
TRC=''

# Remove all files in it:
rm -rf ${RSF}/*

# Create dir, if it doesn't exist yet:
mkdir -p ${RSF}

if [ "$NUM" == "1" ]; then
	PTH='classbench-ng/rules.1'
	python3 pnew.py ${PTH} ${NUM}
	TRC='../classbench-ng/rules.1_trace'
elif [ "$NUM" == "2" ]; then
	PTH='classbench-ng/rules.2'
	python3 pnew.py ${PTH} ${NUM}
	TRC='../classbench-ng/rules.2_trace'
elif [ "$NUM" == "3" ]; then
	PTH='classbench-ng/rules.3'
	python3 pnew.py ${PTH} ${NUM}
	TRC='../classbench-ng/rules.3_trace'
elif [ "$NUM" == "10k" ]; then
	PTH='./dts/dep/test-acl-input/acl1v4_10k_rule'
	python3 pnew.py ${PTH}
	TRC='../dts/dep/test-acl-input/acl1v4_10k_trace'
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
ip netns exec ns1 xdp-loader load -vv enp87s0 app/test-acl/xdp_acl3.o

# Get the status:
sudo ip netns exec ns1 xdp-loader status -vv

# Get the information on the bpf maps:
sudo ip netns exec ns1 bpftool map show >> ../${RSF}/bpfstat.out 2>&1

# Get the id numbers for the two maps:
acl_ctx_id=$(sudo ip netns exec ns1 bpftool map show | grep acl_ctx | cut -d':' -f1 | tr -d ' ')
acl_trans_id=$(sudo ip netns exec ns1 bpftool map show | grep acl_trans | cut -d':' -f1 | tr -d ' ')

#ip netns exec ns1 stdbuf -o0 -e0 ./x86_64-default-linuxapp-gcc13-dbg/app/dpdk-test-acl -n 1 --lcores='1' --no-pci --no-huge --log-level "debug" -- --rulesf=../10k_mod_rule --tracestep=1 --iter=1 --verbose=0 --rulenum=100000 --bpf=${acl_ctx_id}:${acl_trans_id}
#OUT=../${OUT}
ip netns exec ns1 stdbuf -o0 -e0 ./x86_64-default-linuxapp-gcc13-dbg/app/dpdk-test-acl -n 1 --lcores='1' --no-pci --no-huge --log-level "debug" -- --rulesf=../${NUM}_mod_rule --tracef=${TRC} --tracestep=1 --iter=1 --verbose=0 --rulenum=100000 --bpf=${acl_ctx_id}:${acl_trans_id}

#ip netns exec ns1 stdbuf -o0 -e0 ./x86_64-default-linuxapp-gcc13-dbg/app/dpdk-test-acl -n 1 --lcores='1' --no-pci --no-huge --log-level "debug" -- --rulesf=../dts/dep/test-acl-input/acl1v4_10k_rule --tracef=../dts/dep/test-acl-input/acl1v4_10k_trace --tracestep=1 --iter=1 --verbose=0 --rulenum=100000 --bpf=${acl_ctx_id}:${acl_trans_id}


# Leave the directory:
cd ..

# Check that we left;
pwd

# irqs:
/bin/bash -x testpirq.sh ${RSF} 20
#/bin/bash -x test4_2.sh ${RSF} 20

# Move back to directory dpdk-acl-bpf:
cd dpdk-acl-bpf

# Check that we are in directory dpdk-acl-bpf:
pwd

ip netns exec ns1 tcpdump -i enp87s0 &
TCP=$!

# Unload the program:
ip netns exec ns1 xdp-loader unload -a enp87s0 -vv

kill ${TCP}

