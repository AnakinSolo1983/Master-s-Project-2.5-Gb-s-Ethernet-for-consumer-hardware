RSF=${1}
NGINXP=$(<nginxp.txt)
sleep 3
perf record -C 0-3 -o ${RSF}/perf.data sleep 10 > /dev/null 2>&1
