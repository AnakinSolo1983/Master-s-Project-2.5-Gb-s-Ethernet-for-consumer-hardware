#----------

# This Bash script captures the performance data for nginx in the Virtual Machine, which acts as server.

#----------

RSF=${1} # Path to where the data is stored.

NGINXP=$(<nginxp.txt) # Extract the nginx process ID.
sleep 3

# Record performance data for CPU cores 0 to 3, outputting to file perf.data. The command sleeps for 10 seconds while performance data is collected.
perf record -C 0-3 -o ${RSF}/perf.data sleep 10 > /dev/null 2>&1
