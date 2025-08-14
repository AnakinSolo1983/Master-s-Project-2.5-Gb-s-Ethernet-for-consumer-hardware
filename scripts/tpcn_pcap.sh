#!/bin/bash -x

TMT=${1} # Time.
FL=${2}  # File name.
THR=${3} # Number of threads.
CN=${4}  # Number of connections.
RSF=${5} # Run file number.
NUM=${6}

let MPT=TMT/10

PIDS=()

ssh -t olegvm@192.168.122.249 "sudo /bin/bash -x nginx_start.sh"
scp olegvm@192.168.122.249:/home/olegvm/nginxp.txt /home/oleg-ananiev/${RSF}/nginxp.txt

#source ${RSF}/nginxp.txt
NGINXP=$(<${RSF}/nginxp.txt)
# Perform wrk operations for different ports:
ip netns exec ns2 wrk -t${THR} -c${CN} -d${TMT}s --latency http://192.168.11.1:6000/${FL} > ${RSF}/wrk.out1 2>1 &
PIDS+=("${!}") # Get its PID.
ip netns exec ns2 wrk -t${THR} -c${CN} -d${TMT}s --latency http://192.168.11.1:7000/${FL} > ${RSF}/wrk.out2 2>1 &
PIDS+=("${!}")
ip netns exec ns2 wrk -t${THR} -c${CN} -d${TMT}s --latency http://192.168.11.1:6001/${FL} > ${RSF}/wrk.out3 2>1 &
PIDS+=("${!}")
ip netns exec ns2 wrk -t${THR} -c${CN} -d${TMT}s --latency http://192.168.11.1:7001/${FL} > ${RSF}/wrk.out4 2>1 &
PIDS+=("${!}")

ip netns exec ns2 time python3 send_pcap_u6.py dpdk-acl-bpf/rules_${NUM}.pcap enp88s0 100000 ${TMT} > /dev/null 2>1 &
PIDS+=("${!}")

# Get mpstat data:
mpstat -P ALL 10 ${MPT} > ${RSF}/mpstat0.out 2>1 &
PIDS+=("${!}")

#cat /proc/interrupts | grep enp88s0-TxRx >> ${RSF}/irqaft.out 2>1

ssh -t olegvm@192.168.122.249 "sudo /bin/bash -x perf_get.sh ${RSF}"
ssh -t olegvm@192.168.122.249 "sudo /bin/bash -x perfcp.sh ${RSF}"
scp olegvm@192.168.122.249:/home/olegvm/${RSF}/perf.data /home/oleg-ananiev/${RSF}

wait ${PIDS[@]}
#scp olegvm@192.168.122.249:/home/olegvm/perf.data /home/oleg-ananiev/${RSF}
ssh -t olegvm@192.168.122.249 "sudo /bin/bash -x nginx_kill.sh"


