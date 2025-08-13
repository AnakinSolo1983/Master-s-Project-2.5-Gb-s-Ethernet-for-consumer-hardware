#!/bin/bash -x

#----------

# This Bash script performs a performance test on an nginx server (started on a namespace ns1) for Netfilter iptables using the wrk tool (started on namespace ns2). It accepts parameters for time, file name, number of threads, number of connections, and run file number. It executes multiple concurrent requests to measure the server's performance.

#----------

TMT=${1} # Time to run the test in seconds.
FL=${2}  # File name.
THR=${3} # Number of threads.
CN=${4}  # Number of connections.
RSF=${5} # Run file number.

let MPT=TMT/10 # The interval for mpstat.

PIDS=() # An array to sote process IDs for nginx and wrk.

# Start the server:
ip netns exec ns1 nginx -c nginx.conf/nginx-cpus-cores-lp4.conf &
NGINX_PID=$! # Get the PID of the nginx process.
echo "Nginx PID: ${NGINX_PID}"
sleep 5 # Give it time to setup.
ps -ef | grep nginx # Verifying that nginx is working.

# Perform wrk operations for different ports:
ip netns exec ns2 wrk -t${THR} -c${CN} -d${TMT}s --latency http://192.168.11.1:6000/${FL} > ${RSF}/wrk.out1 2>1 &
PIDS+=("${!}") # Get its PID.
ip netns exec ns2 wrk -t${THR} -c${CN} -d${TMT}s --latency http://192.168.11.1:7000/${FL} > ${RSF}/wrk.out2 2>1 &
PIDS+=("${!}")
ip netns exec ns2 wrk -t${THR} -c${CN} -d${TMT}s --latency http://192.168.11.1:6001/${FL} > ${RSF}/wrk.out3 2>1 &
PIDS+=("${!}")
ip netns exec ns2 wrk -t${THR} -c${CN} -d${TMT}s --latency http://192.168.11.1:7001/${FL} > ${RSF}/wrk.out4 2>1 &
PIDS+=("${!}")

# Get mpstat (CPU statistics) data:
mpstat -P ALL 10 ${MPT} > ${RSF}/mpstat0.out 2>1 &
PIDS+=("${!}")

sleep 3 # This is done to give mpstat time to start.

# Record the performance data, i.e. the data of cpu time
perf record -C 0-3 -o ${RSF}/perf.data sleep 10 > /dev/null 2>&1

wait ${PIDS[@]} # Wait for all background processes to complete.

# Kill the Nginx process using its process ID:
kill ${NGINX_PID}
ps -ef | grep nginx # Check if it is terminated. 

