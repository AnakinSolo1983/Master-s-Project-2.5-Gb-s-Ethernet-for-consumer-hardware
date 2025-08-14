#!/bin/bash -x
RSF=${1}

SERVER=sudo lshw -c network -businfo

rm -rf ${RSF}/*
mkdir -p ${RSF}
# See the information on interrupts assigned to server before:
echo "ns1 Before: " >> ${RSF}/sirqstat.out 2>1
cat /proc/interrupts | grep enp7s0-TxRx >> ${RSF}/sirqstat.out 2>1

# Assign interrupts to CPU cores for server:
IRQS=($(cat /proc/interrupts | grep enp7s0-TxRx | awk '{print $1}' | tr -d :)); i=0; while [[ i -ne ${#IRQS[@]} ]]; 
do 
	echo "${i}: ${IRQS[${i}]}"; 
	echo $i > /proc/irq/${IRQS[${i}]}/smp_affinity_list;  
	#echo "0-3" > /proc/irq/${IRQS[${i}]}/smp_affinity_list;  
	cat /proc/irq/${IRQS[${i}]}/smp_affinity*; 
	let i++;  
done >> ${RSF}/sirqstat.out 2>1

# Seeto which cores these interrupts are assigned:
IRQS=($(cat /proc/interrupts | grep enp7s0-TxRx | awk '{print $1}' | tr -d :)); 
i=0; 
while [[ i -ne ${#IRQS[@]} ]]; 
do 
	echo "${i}: ${IRQS[${i}]}"; 
	cat /proc/irq/${IRQS[${i}]}/effective_affinity*; 
	let i++;  
done >> ${RSF}/sirqstat.out 2>1

# See the information on interrupts assigned to server after:
echo "ns1 After: " >> /${RSF}/sirqstat.out 2>1
cat /proc/interrupts | grep enp7s0-TxRx >> ${RSF}/sirqstat.out 2>1


ls -l ${RSF}/sirqstat.out
chmod 644 ${RSF}/sirqstat.out
ls -l ${RSF}/sirqstat.out

