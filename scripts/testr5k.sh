
COUNT=0;

python3 ../p5k_xdp.py  | while read line; do
    pcn-iptables $line
    ((COUNT++))
    echo $COUNT
done

pcn-iptables -L INPUT > rules0_r5k.1
