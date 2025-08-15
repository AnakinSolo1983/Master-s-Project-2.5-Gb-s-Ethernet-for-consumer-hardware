
COUNT=0;

python3 ../p_dts_aclv4_10k_xdp.py  | while read line; do
    pcn-iptables $line
    ((COUNT++))
    echo $COUNT
done

pcn-iptables -L INPUT > rules0_r3.1
