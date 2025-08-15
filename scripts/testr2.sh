python3 ../p2_xdp.py | while read line; do
    pcn-iptables $line
done

pcn-iptables -L INPUT > rules0_r2.1
#pcn-iptables-clean
