python3 ../p1_xdp.py | while read line; do
    pcn-iptables $line
done

pcn-iptables -L INPUT > rules0_r1.1
#pcn-iptables-clean
