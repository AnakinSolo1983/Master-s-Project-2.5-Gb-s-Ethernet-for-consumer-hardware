pwd
#sudo -S /bin/bash
#pwd
#sudo -S ip netns exec ns1 nginx -c /home/olegvm/nginx.conf/nginx-cpus-cores-lp4.conf &
#ip netns exec ns1 nginx -c /home/olegvm/nginx.conf/nginx-cpus-cores-lp4.conf
#echo "Kamenka94" | sudo -S ip netns exec ns1 nginx -c /home/olegvm/nginx.conf/nginx-cpus-cores-lp4.con


# kill all running instances of nginx
systemctl disable nginx
systemctl stop nginx
#systemctl status nginx

kill $(pgrep nginx)

ps -ef | grep nginx

nginx -c /home/olegvm/nginx.conf/nginx-cpus-cores-lp4.conf &
NGINX_PID=$! # Get the PID.
echo "Nginx PID: ${NGINX_PID}" 
echo $NGINX_PID > nginxp.txt
sleep 5 # Give it time to setup.
ps -ef | grep nginx

#pwd

