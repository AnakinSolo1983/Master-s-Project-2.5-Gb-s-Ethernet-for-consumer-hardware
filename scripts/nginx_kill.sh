
#----------

# This Bash script only terminates the nginx process after the testing and verifies that it is done successfully.

#----------

NGINXP=$(<nginxp.txt) # Extract the process ID for nginx.
kill ${NGINXP} # Terminate the process.
ps -ef | grep nginx # Check that it is.
