
import os
import csv
import sys
os.sys.path.append('/usr/lib/python3.11/site-packages')
from scapy.all import *

sz = int(sys.argv[5])
tcp_hdrsz = 58
udp_hdrsz = 46

with open(sys.argv[1],'r') as f:
    lines = list(csv.reader(f, delimiter = '\t', skipinitialspace = True))
    pkt=[]
    for i in range(len(lines)):
        sip = int(lines[i][0])
        dip = int(lines[i][1])
        sp = int(lines[i][2])
        dp = int(lines[i][3])
        if (sp == 0) :
            sp = sp + 1
        if (dp == 0) :
            dp = dp + 1
        proto= int(lines[i][4])
        sipstr=('{:d}.{:d}.{:d}.{:d}' .format(int(sip/0x1000000)%256, int(sip/0x10000)%256, int(sip/0x100)%256, int(sip)%256))
        dipstr=('{:d}.{:d}.{:d}.{:d}' .format(int(dip/0x1000000)%256, int(dip/0x10000)%256, int(dip/0x100)%256, int(dip)%256))
        if (proto == 6) :
            if (dp == 53) :
                p=Ether(src=sys.argv[3],dst=sys.argv[4])/IP(src=sipstr,dst=dipstr)/TCP(sport=sp,dport=dp)/DNS(rd=1, qd=DNSQR(qname='www.XXX.org'))
            else :
                p=Ether(src=sys.argv[3],dst=sys.argv[4])/IP(src=sipstr,dst=dipstr)/TCP(sport=sp,dport=dp)/Raw('X' * (sz - tcp_hdrsz))
        elif (proto == 17) :
            if (dp == 53) :
                p=Ether(src=sys.argv[3],dst=sys.argv[4])/IP(src=sipstr,dst=dipstr)/UDP(sport=sp,dport=dp)/DNS(rd=1, qd=DNSQR(qname='www.YYY.org'))
            else :
                p=Ether(src=sys.argv[3],dst=sys.argv[4])/IP(src=sipstr,dst=dipstr)/UDP(sport=sp,dport=dp)/Raw('Y' * (sz - udp_hdrsz))
        else :
            p=Ether(src=sys.argv[3],dst=sys.argv[4])/IP(src=sipstr,dst=dipstr,proto=proto)/Raw(UDP(sport=sp,dport=dp)/Raw('Z' * (sz - udp_hdrsz)))
        pkt += p
    wrpcap(sys.argv[2], pkt)
