#----------

# This is a vital Bash script that creates and configures two network namespaces. Namespace ns1 shall act as server, while ns2 shall act as client that will be sending traffic to the former. The script includes assigning NICs and ip addresses to the namespaces.

#----------

# Create namespace ns1.
ip netns add ns1

# Move the network interface enp87s0 into the namespace ns1.
ip link set dev enp87s0 netns ns1

# Bring the interface enp87s0 up within the namespace ns2.
ip netns exec ns1 ip link set dev enp87s0 up

# Assign an IP address to the interface enp87s0 in the namespace ns1.
ip netns exec ns1 ip addr add dev enp87s0 192.168.11.1/24

# Create namespace ns2.
ip netns add ns2

# Move the network interface enp88s0 into the namespace ns2.
ip link set dev enp88s0 netns ns2

# Bring the interface enp88s0 up within the namespace ns2.
ip netns exec ns2 ip link set dev enp88s0 up

# Assign an IP address to the interface enp88s0 in the namespace ns2.
ip netns exec ns2 ip addr add dev enp88s0 192.168.11.10/24
