#!/bin/bash -x

#----------

# This Bash script gathers information about the irqs for the Virtual Machine (VM) acting as server, after the testing.

#----------

RSF=${1} # Path to where the data will be stored.
echo "ns1 After: " >> ${RSF}/sirqaft.out 2>&1
cat /proc/interrupts | grep enp7s0-TxRx >> ${RSF}/sirqaft.out 2>&1 # Store it in a file sirqaft.out.
