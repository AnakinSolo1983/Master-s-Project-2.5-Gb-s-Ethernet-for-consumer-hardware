#!/bin/bash -x

RSF=${1}

# See the information on interrupts assigned to client before:
echo "ns2 Before: " >> ${RSF}/irqstat.out 2>1
cat /proc/interrupts | grep enp88s0-TxRx >> ${RSF}/irqstat.out 2>1

# Assign these interrupts to cores from 4 to 15:
IRQS=($(cat /proc/interrupts | grep enp88s0-TxRx | awk '{print $1}' | tr -d :));
i=0;
while [[ i -ne ${#IRQS[@]} ]];
do
 echo "${i}: ${IRQS[${i}]}";
 echo "4-15" > /proc/irq/${IRQS[${i}]}/smp_affinity_list;
 cat /proc/irq/${IRQS[${i}]}/smp_affinity*;
 let i++;
done >> ${RSF}/irqstat.out 2>1

# See to which cores these interrupts are assigned:
IRQS=($(cat /proc/interrupts | grep enp88s0-TxRx | awk '{print $1}' | tr -d :)); 
i=0; while [[ i -ne ${#IRQS[@]} ]]; 
do 
	echo "${i}: ${IRQS[${i}]}"; 
	cat /proc/irq/${IRQS[${i}]}/effective_affinity*; 
	let i++;  
done >> ${RSF}/irqstat.out 2>1

