#!/bin/bash -x

TMT=${1} # Time.
FL=${2}  # File name.
THR=${3} # Number of threads.
CN=${4}  # Number of connections.
RSF=${5} # Run file number.

let MPT=TMT/10

PIDS=()

# Start the server:
ip netns exec ns1 nginx -c /home/oleg-ananiev/nginx.conf/nginx-cpus-cores-lp4.conf &
NGINX_PID=$! # Get the PID.
echo "Nginx PID: ${NGINX_PID}"
sleep 5 # Give it time to setup.
ps -ef | grep nginx

# Perform wrk operations for different ports:
ip netns exec ns2 wrk -t${THR} -c${CN} -d${TMT}s --latency http://192.168.11.1:6000/${FL} > ${RSF}/wrk.out1 2>1 &
PIDS+=("${!}") # Get its PID.
ip netns exec ns2 wrk -t${THR} -c${CN} -d${TMT}s --latency http://192.168.11.1:7000/${FL} > ${RSF}/wrk.out2 2>1 &
PIDS+=("${!}")
ip netns exec ns2 wrk -t${THR} -c${CN} -d${TMT}s --latency http://192.168.11.1:6001/${FL} > ${RSF}/wrk.out3 2>1 &
PIDS+=("${!}")
ip netns exec ns2 wrk -t${THR} -c${CN} -d${TMT}s --latency http://192.168.11.1:7001/${FL} > ${RSF}/wrk.out4 2>1 &
PIDS+=("${!}")

# Get mpstat data:
mpstat -P ALL 10 ${MPT} > ${RSF}/mpstat0.out 2>1 &
PIDS+=("${!}")

sleep 3 #3
perf record -C 0-3 -o ${RSF}/perf.data sleep 10 > /dev/null 2>&1
#PF_ID=$!
#wait #PF_ID #(for perf to be done)
#perf report #-o ${RSF}.perf.out

wait ${PIDS[@]}

# Kill the Nginx process using its PID:
kill ${NGINX_PID}
ps -ef | grep nginx #check if it is terminated. 

