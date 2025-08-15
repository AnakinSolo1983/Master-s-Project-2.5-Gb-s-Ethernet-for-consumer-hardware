#----------

# This Bash script is used to set up an nginx instance for Virtual Machine. It includes terminating all running instances of nginx before.

#----------

pwd # Check our current location.

# Kill all running instances of nginx:
systemctl disable nginx
systemctl stop nginx

kill $(pgrep nginx)

# Verify that it worked:
ps -ef | grep nginx

# Start the server:
nginx -c /home/olegvm/nginx.conf/nginx-cpus-cores-lp4.conf &
NGINX_PID=$! # Get the PID.
echo "Nginx PID: ${NGINX_PID}" 
echo $NGINX_PID > nginxp.txt # Store the process ID into a file.
sleep 5 # Give it time to setup.
ps -ef | grep nginx # Verify that it is running.
