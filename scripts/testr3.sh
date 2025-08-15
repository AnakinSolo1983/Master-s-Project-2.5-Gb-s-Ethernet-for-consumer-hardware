python3 ../p3_xdp.py | while read line; do
    pcn-iptables $line
done

pcn-iptables -L INPUT > rules0_r3.1
#pcn-iptables-clean
