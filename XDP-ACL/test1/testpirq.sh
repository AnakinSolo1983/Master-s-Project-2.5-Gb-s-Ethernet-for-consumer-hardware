#!/bin/bash -x

RSF=${1}
TIME=${2}

#rm -rf ${RSF}/*
#mkdir -p ${RSF}

#before=$(cat /proc/meminfo | grep 'MemAvailable')

# Get pci for enp87s0: 0000:57:00.0
SERVER=ip netns exec ns1 sudo lshw -c network -businfo

# Get pci for enp88s0: 0000:58:00.0
CLIENT=ip netns exec ns2 sudo lshw -c network -businfo

# Which interrupts are assigned
ip netns exec ns2 cat /proc/interrupts | grep ${CLIENT}

#IRQS=($(cat /proc/interrupts | grep enp87s0-TxRx | awk '{print $1}' | tr -d :)); i=0; while [[ i -ne ${#IRQS[@]} ]]; do echo "${i}: ${IRQS[${i}]}"; let i++; done

#IRQS=($(cat /proc/interrupts | grep enp87s0-TxRx | awk '{print $1}' | tr -d :)); i=0; while [[ i -ne ${#IRQS[@]} ]]; do echo "${i}: ${IRQS[${i}]}"; cat /proc/irq/${IRQS[${i}]}/smp_affinity*; let i++;  done

#IRQS=($(cat /proc/interrupts | grep enp87s0-TxRx | awk '{print $1}' | tr -d :)); i=0; while [[ i -ne ${#IRQS[@]} ]]; do echo "${i}: ${IRQS[${i}]}"; echo $i > /proc/irq/${IRQS[${i}]}/smp_affinity_list;  cat /proc/irq/${IRQS[${i}]}/smp_affinity*; let i++;  done

#IRQS=($(cat /proc/interrupts | grep enp87s0-TxRx | awk '{print $1}' | tr -d :)); i=0; while [[ i -ne ${#IRQS[@]} ]]; do echo "${i}: ${IRQS[${i}]}"; cat /proc/irq/${IRQS[${i}]}/effective_affinity*; let i++;  done

# See the information on interrupts assigned to server before:
echo "ns1 Before: " >> ${RSF}/irqstat.out 2>1
cat /proc/interrupts | grep enp87s0-TxRx >> ${RSF}/irqstat.out 2>1

# Assign interrupts to CPU cores for server:
IRQS=($(cat /proc/interrupts | grep enp87s0-TxRx | awk '{print $1}' | tr -d :)); i=0; while [[ i -ne ${#IRQS[@]} ]]; 
do 
	echo "${i}: ${IRQS[${i}]}"; 
	echo $i > /proc/irq/${IRQS[${i}]}/smp_affinity_list;  
	cat /proc/irq/${IRQS[${i}]}/smp_affinity*; 
	let i++;  
done >> ${RSF}/irqstat.out 2>1

# Seeto which cores these interrupts are assigned:
IRQS=($(cat /proc/interrupts | grep enp87s0-TxRx | awk '{print $1}' | tr -d :)); 
i=0; 
while [[ i -ne ${#IRQS[@]} ]]; 
do 
	echo "${i}: ${IRQS[${i}]}"; 
	cat /proc/irq/${IRQS[${i}]}/effective_affinity*; 
	let i++;  
done >> ${RSF}/irqstat.out 2>1


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

# Run the script performing the test:
/bin/bash -x testpap.sh ${TIME} hello 12 1000 ${RSF}
#/bin/bash -x testp4.sh ${TIME} hello 12 1000 ${RSF}

# See the information on interrupts assigned to server after:
echo "ns1 After: " >> ${RSF}/irqstat.out 2>1
cat /proc/interrupts | grep enp87s0-TxRx >> ${RSF}/irqstat.out 2>1

echo "-----" >> ${RSF}/irqstat.out 2>1

# See the information on interrupts assigned to client after:
echo "ns2 After: " >> ${RSF}/irqstat.out 2>1
cat /proc/interrupts | grep enp88s0-TxRx >> ${RSF}/irqstat.out 2>1

#after=$(cat /proc/meminfo | grep 'MemAvailable')

#before_val=$(echo $before | awk '{print $2}')
#after_val=$(echo $after | awk '{print $2}')
#unit=$(echo $before | awk '{print $3}')

#echo "Memory available before: $before_val $unit"
#echo "Memory available after: $after_val $unit"

#musage=$((before_val-after_val))
#echo "Memory usage: $musage $unit"

# Get the information on Requests/sec and calculate the sum:
grep 'Requests/sec' ${RSF}/wrk.out? >> ${RSF}/wrkstat.out
grep 'Requests/sec' ${RSF}/wrk.out? | awk '{x=$2; sum+=x; printf("%s %f\n", $(2), sum);}' >> ${RSF}/wrkstat.out

