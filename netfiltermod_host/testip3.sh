#!/bin/bash -x

RSF=${1}
NUM=${2}

RSF=host/run${RSF}
#remove all files in it
rm -rf ${RSF}/*
#create dir, if it doesn't exist yet
mkdir -p ${RSF}

#TEMP='_acl2_10k'
if [ "$NUM" != "0" ]; then
	rule_count=$(ip netns exec ns1 sudo iptables -L -n | grep -c '^[A-Z]')
	before=$(cat /proc/meminfo | grep 'MemAvailable')
	echo "Number of iptables rules: $rule_count"
	python3 p${NUM}_c.py | while read line; do
		ip netns exec ns1 /usr/sbin/iptables-legacy $line
	done
	
	after=$(cat /proc/meminfo | grep 'MemAvailable')
	echo "Checking before:"; >> ${RSF}/ipcheck.out 2>1
	ip netns exec ns1 /usr/sbin/iptables-legacy -L -v -n 
	ip netns exec ns1 /usr/sbin/iptables-legacy -L -v -n >> netflt/run${RSF}/ipcheck.out 2>1
	echo " "; >> ${RSF}/ipstat.out 2>1
	echo "-----"; >> ${RSF}/ipstat.out 2>1
	echo " "; >> ${RSF}/ipstat.out 2>1
	ip netns exec ns1 /usr/sbin/iptables-legacy -L INPUT


fi

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



/bin/bash -x test4_2.sh ${RSF} 20

echo " "; >> ${RSF}/ipstat.out 2>1
echo "-----"; >> ${RSF}/ipstat.out 2>1
echo " "; >> ${RSF}/ipstat.out 2>1

# Check iptables rules
ip netns exec ns1 /usr/sbin/iptables-legacy -L -v -n >> netflt/run${RSF}/ipstat.out 2>1

echo "----------"; >> ${RSF}/ipstat.out 2>1

# Print statistics for dropped packets
echo "Dropped packets:" >> ${RSF}/ipstat.out 2>1
ip netns exec ns1 /usr/sbin/iptables-legacy -L -v -n | grep "DROP"

ip netns exec ns1 /usr/sbin/iptables-legacy -L -v -n | grep "DROP" >> ${RSF}/ipstat.out 2>1

#echo "Accepted packets from 192.168.11.10:"
#ip netns exec ns1 sudo iptables -L -v -n | grep "ACCEPT" >> netflt/run${RSF}.ipstat.out 2>1

echo " "; >> ${RSF}/ipstat.out 2>1

rule_count=$(ip netns exec ns1 sudo iptables -L -n | grep -c '^[A-Z]')
#after=$(cat /proc/meminfo | grep 'MemAvailable')

echo "Number of iptables rules: $rule_count"
#echo "Memory available after: $after"



if [ "$NUM" != "0" ]; then
	echo "Deleting rules:"; >> ${RSF}/ipstat.out 2>1
	ip netns exec ns1 /usr/sbin/iptables-legacy -F INPUT >> ${RSF}/ipstat.out 2>1
	ip netns exec ns1 /usr/sbin/iptables-legacy -F INPUT
	#sudo apt install iptables-persistent
	echo " "; >> ${RSF}/ipstat.out 2>1
	echo "-----"; >> ${RSF}/ipstat.out 2>1
	echo " "; >> ${RSF}/ipstat.out 2>1
	
	echo "Checking:"; >> ${RSF}/ipcheck.out 2>1
	ip netns exec ns1 /usr/sbin/iptables-legacy -L -v -n >> ${RSF}/ipcheck.out 2>1

fi


