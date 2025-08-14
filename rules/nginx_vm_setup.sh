#ip netns add ns1

#ip link set dev enp7s0 netns ns1
ip link set dev enp7s0 up

ip addr add dev enp7s0 192.168.11.1/24


#ip netns add ns2

#ip link set dev enp8s0 netns ns2

#ip netns exec ns2 ip link set dev enp8s0 up

#ip netns exec ns2 ip addr add dev enp8s0 192.168.11.10/24
