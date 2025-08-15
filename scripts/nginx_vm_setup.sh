#----------

# This Bash script is vital when testing for pcn-iptables. It configures the network interface for the server (VM), assigning an ip address to it.

#----------

# Enable the network interface enp7s0
ip link set dev enp7s0 up

# Assign the IP address 192.168.11.1 with a subnet mask of /24 to enp7s0:
ip addr add dev enp7s0 192.168.11.1/24
