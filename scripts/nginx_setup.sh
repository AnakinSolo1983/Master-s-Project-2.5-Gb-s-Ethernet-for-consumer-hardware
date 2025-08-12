ip netns add ns1

ip link set dev enp87s0 netns ns1

ip netns exec ns1 ip link set dev enp87s0 up

ip netns exec ns1 ip addr add dev enp87s0 192.168.11.1/24
#ssh -t olegvm@192.168.122.249 "/bin/bash -x nginx_setup.sh"


ip netns add ns2

ip link set dev enp88s0 netns ns2

ip netns exec ns2 ip link set dev enp88s0 up

ip netns exec ns2 ip addr add dev enp88s0 192.168.11.10/24

