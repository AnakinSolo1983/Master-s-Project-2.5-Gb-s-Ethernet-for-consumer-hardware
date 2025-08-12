#!/bin/bash -x

RSF=${1}
NUM=${2}
#TYP=${3}


#TEMP='_acl2_10k'
#if 

RSF=host/run${RSF}
#remove all files in it
rm -rf ${RSF}/*
#create dir, if it doesn't exist yet
mkdir -p ${RSF}


rule_count=$(ip netns exec ns1 sudo iptables -L -n | grep -c '^[A-Z]')
before=$(cat /proc/meminfo | grep 'MemAvailable')

echo "Number of iptables rules: $rule_count"
#echo "Memory available before: $before"

python3 p${NUM}.py | while read line; do
    ip netns exec ns1 iptables $line
done


# -----
#while IFS= read -r line; do
 #   IFS=$'\t' read -r src dest src_ports dest_ports _ <<< "${line//@/}"
  #  ip netns exec ns1 iptables -A INPUT -s ${src} -d ${dest} --sport ${src_ports} --dport ${dest_ports} -j DROP
#done < classbench-ng/rules.1

#while IFS= read -r line; do
    #IFS=$'\t' read -r src dest src_ports dest_ports _ <<< "${line//@/}"
    
    #ip netns exec ns1 iptables -A INPUT -p tcp -s ${src} -d ${dest} --sport ${src_ports} --dport ${dest_ports} -j DROP
#done < classbench-ng/rules.1

#while read -r line; do     
	#set -- $line;
	#source=$(echo "$1" | awk '{print $1}')  
	#dest=$(echo "$2" | awk '{print $2}')
	#sports=$(echo "$3:$5" | awk '{print $3:$5}')
	#source=$(echo "$6:$8" | awk '{print $6:$8}')   
	#echo "$1 $2 $3:$5 $6:$8"; 
	#iptables -A INPUT -p tcp -s "$source" -d "$dest" --sport "$sports" --dport "$dports" -j ACCEPT
#done < classbench-ng/rules.1


#while IFS= read -r line; do
    # Extracting the fields from the line
    #source=$(echo "$line" | awk '{print $1}' | sed 's/@//')
    #dest=$(echo "$line" | awk '{print $2}')
    #sports=$(echo "$line" | awk '{print $3}' | sed 's/ :/:/g')
    #dports=$(echo "$line" | awk '{print $4}' | sed 's/ :/:/g')

    # Generating iptables rule
    #iptables -A INPUT -p tcp -s "$source" -d "$dest" --sport "$sports" --dport "$dports" -j ACCEPT
#done < classbench-ng/rules.1

#ip netns exec ns1 iptables -A INPUT -s 203.0.113.51 -j DROP -m comment --comment "Unacceptable :("

#ip netns exec ns1 iptables -A INPUT -s 192.168.11.10 -j ACCEPT -m comment --comment "Welcome ;)"

#ip netns exec ns1 iptables -A INPUT -d 192.168.11.1 -j ACCEPT -m comment --comment "That is me!"

#sudo apt install iptables-persistent
#iptables-save -f /etc/iptables/iptables.rules
#sudo iptables -L --line-numbers
#------

after=$(cat /proc/meminfo | grep 'MemAvailable')

echo "Checking before:"; >> ${RSF}/ipcheck.out 2>1
#echo "Checking before:"; >> ${RSF}.ipcheck.out 2>1
ip netns exec ns1 sudo iptables -L -v -n 
ip netns exec ns1 sudo iptables -L -v -n >> netflt/run${RSF}/ipcheck.out 2>1

echo " "; >> ${RSF}/ipstat.out 2>1
echo "-----"; >> ${RSF}/ipstat.out 2>1
echo " "; >> ${RSF}/ipstat.out 2>1

sudo iptables -L INPUT

/bin/bash -x test4_2.sh ${RSF} 20

echo " "; >> ${RSF}/ipstat.out 2>1
echo "-----"; >> ${RSF}/ipstat.out 2>1
echo " "; >> ${RSF}/ipstat.out 2>1

# Check iptables rules
ip netns exec ns1 sudo iptables -L -v -n >> netflt/run${RSF}/ipstat.out 2>1

echo "----------"; >> ${RSF}/ipstat.out 2>1

# Print statistics for dropped packets
echo "Dropped packets:" >> ${RSF}/ipstat.out 2>1
ip netns exec ns1 sudo iptables -L -v -n | grep "DROP"

ip netns exec ns1 sudo iptables -L -v -n | grep "DROP" >> ${RSF}/ipstat.out 2>1

#echo "Accepted packets from 192.168.11.10:"
#ip netns exec ns1 sudo iptables -L -v -n | grep "ACCEPT" >> netflt/run${RSF}.ipstat.out 2>1

echo " "; >> ${RSF}/ipstat.out 2>1

rule_count=$(ip netns exec ns1 sudo iptables -L -n | grep -c '^[A-Z]')
#after=$(cat /proc/meminfo | grep 'MemAvailable')

echo "Number of iptables rules: $rule_count"
#echo "Memory available after: $after"

before_val=$(echo $before | awk '{print $2}')
after_val=$(echo $after | awk '{print $2}')
unit=$(echo $before | awk '{print $3}')

echo "Memory available before: $before_val $unit"
echo "Memory available after: $after_val $unit"

musage=$((before_val-after_val))
echo "Memory usage: $musage $unit"

echo "Deleting rules:"; >> ${RSF}/ipstat.out 2>1
ip netns exec ns1 sudo iptables -F INPUT >> ${RSF}/ipstat.out 2>1
#iptables -D INPUT -s 203.0.113.51 -j DROP
#ip netns exec ns1 iptables -D INPUT -s 192.168.11.10 -j ACCEPT
ip netns exec ns1 sudo iptables -F INPUT

sudo apt install iptables-persistent

echo " "; >> ${RSF}/ipstat.out 2>1
echo "-----"; >> ${RSF}/ipstat.out 2>1
echo " "; >> ${RSF}/ipstat.out 2>1

echo "Checking:"; >> ${RSF}/ipcheck.out 2>1
ip netns exec ns1 sudo iptables -L -v -n >> ${RSF}/ipcheck.out 2>1
#iptables-save -f /etc/iptables/iptables.rules

#sudo iptables -L INPUT
