
import os
import sys
os.sys.path.append('/usr/lib/python3.11/site-packages')
from scapy.all import *

steplen = int(sys.argv[3])
numsec = int(sys.argv[4])

pkt=rdpcap(sys.argv[1])
plen=len(pkt)

i = 0
t = 0
while i < numsec: 
    print(f"Second {i}")
    start = (i * steplen) % plen
    end = start + steplen
    if end > plen:
        end = plen
    sendp(pkt[start:end], iface=sys.argv[2])
    t += (end - start)
    i = i + 1
    #time.sleep(1)

print(f"Total seconds: {i}, packets sent: {t}")
