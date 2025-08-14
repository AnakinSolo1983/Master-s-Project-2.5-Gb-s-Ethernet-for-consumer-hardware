#!/bin/bash -x

RSF=${1}
TYP=${2}
NUM=${3}

if [ "$TYP" == "0" ]; then
    RSF=result/pcn/pcap/r0/run${RSF}
    rm -rf ${RSF}/*
    mkdir -p ${RSF}
elif [ "$TYP" == "net" ]; then
    RSF=result/pcn/pcap/netflt/run${RSF}
    rm -rf ${RSF}/*
    mkdir -p ${RSF}
    ssh -t olegvm@192.168.122.249 "sudo /bin/bash -x netflt.sh ${NUM}"
elif [ "$TYP" == "xdp" ]; then
    RSF=result/pcn/pcap/xdp/run${RSF}
    rm -rf ${RSF}/*
    mkdir -p ${RSF}
    ssh -t olegvm@192.168.122.249 "sudo /bin/bash -x xdp.sh ${NUM}"
elif [ "$TYP" == "pcap" ]; then
    RSF=result/pcn/pcap/run${RSF}
    rm -rf ${RSF}/*
    mkdir -p ${RSF}
    ssh -t olegvm@192.168.122.249 "sudo /bin/bash -x xdp.sh ${NUM}"
fi

ssh -t olegvm@192.168.122.249 "sudo /bin/bash -x servirq.sh ${RSF}"

scp olegvm@192.168.122.249:/home/olegvm/${RSF}/sirqstat.out /home/oleg-ananiev/${RSF}

/bin/bash -x t_pcn_irq.sh ${RSF}
/bin/bash -x taclssh.sh 20 hello 12 1000 ${RSF} ${NUM}

# Get the information on Requests/sec and calculate the sum:
grep 'Requests/sec' ${RSF}/wrk.out? >> ${RSF}/wrkstat.out
grep 'Requests/sec' ${RSF}/wrk.out? | awk '{x=$2; sum+=x; printf("%s %f\n", $(2), sum);}' >> ${RSF}/wrkstat.out

ssh -t olegvm@192.168.122.249 "sudo /bin/bash -x irqaft.sh ${RSF}"
echo "ns2 After: " >> ${RSF}/irqstat.out 2>&1
cat /proc/interrupts | grep enp88s0-TxRx >> ${RSF}/irqstat.out 2>1

scp olegvm@192.168.122.249:/home/olegvm/${RSF}/sirqaft.out /home/oleg-ananiev/${RSF}

if [ "$TYP" == "net" ]; then
    scp olegvm@192.168.122.249:/home/olegvm/rulesN_r${NUM}.1 /home/oleg-ananiev/${RSF}
    ssh -t olegvm@192.168.122.249 "sudo /bin/bash -x sudo iptables -F INPUT"
elif [ "$TYP" == "xdp" ]; then
    scp olegvm@192.168.122.249:/home/olegvm/polycube/rules0_r${NUM}.1 /home/oleg-ananiev/${RSF}
    ssh -t olegvm@192.168.122.249 "sudo /bin/bash -x pcn-iptables-clean"
elif [ "$TYP" == "pcap" ]; then
    scp olegvm@192.168.122.249:/home/olegvm/polycube/rules0_r${NUM}.1 /home/oleg-ananiev/${RSF}
    ssh -t olegvm@192.168.122.249 "sudo /bin/bash -x pcn-iptables-clean"
fi
