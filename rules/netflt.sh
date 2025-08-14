NUM=${1}
#COUNT=0;
#python3 p${NUM}_c.py | while read line; do
python3 p${NUM}.py | while read line; do
    iptables $line
    #((COUNT++))
    #echo $COUNT
done

#echo $COUNT
iptables -L -v -n > rulesN_r${NUM}.1
#ip netns exec ns1 sudo iptables -F INPUT
