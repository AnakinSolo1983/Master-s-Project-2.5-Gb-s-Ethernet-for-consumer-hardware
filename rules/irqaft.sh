#!/bin/bash -x

RSF=${1}
echo "ns1 After: " >> ${RSF}/sirqaft.out 2>&1
cat /proc/interrupts | grep enp7s0-TxRx >> ${RSF}/sirqaft.out 2>&1
