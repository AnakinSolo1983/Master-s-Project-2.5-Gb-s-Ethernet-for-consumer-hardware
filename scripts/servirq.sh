#!/bin/bash -x

#----------

# This is a vital Bash script which assigns irqs to the cores for server (VM). In addition it verifies that the assignment has been done. Also, it handles permissions to the data file so that it can be copied to the host machine where all data for the test will be stored.

#----------

RSF=${1} # Path to where the data is stored.

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
	cat /proc/irq/${IRQS[${i}]}/smp_affinity*; 
	let i++;  
done >> ${RSF}/sirqstat.out 2>1

# See to which cores these interrupts are assigned:
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

