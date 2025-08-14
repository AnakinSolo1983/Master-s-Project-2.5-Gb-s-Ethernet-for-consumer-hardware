#source nginxp.txt
NGINXP=$(<nginxp.txt)
kill ${NGINXP}
ps -ef | grep nginx
