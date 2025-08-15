from ipaddress import IPv4Address, IPv4Network
#num=1
with open('../classbench-ng/rules.3', 'r') as file:
    for line in file:
        parts = line.strip().split('\t')
        source = parts[0][1:]  # Remove the '@'
        dest = parts[1]
        source_ports = parts[2].replace(' : ', ':')
        dest_ports = parts[3].replace(' : ', ':')
        #if IPv4Address('192.168.11.10/24') in IPv4Network('0.0.0.0/0') and IPv4Address('192.168.11.1/24') in IPv4Network('128.0.0.0/1'):
        #	continue
        if IPv4Address('192.168.11.10') in IPv4Network(source) and IPv4Address('192.168.11.1') in IPv4Network(dest):
        	continue
        
        if source == '0.0.0.0/0' and source == dest:
        	continue
        
        val1,val2 = dest_ports.split(':')
        if int(val1) != int(val2):
                if int(val1) != 0 or int(val2) != 65535:
                        continue
        		#dest_ports = '0:65525'
        
        
        # Generate iptables rule
        #rule = f"iptables -A INPUT -s {source} -d {dest} -p tcp --sport {source_ports} --dport {dest_ports} -j ACCEPT"
        rule = f"-A INPUT -s {source} -d {dest} -p tcp --sport {source_ports} --dport {dest_ports} -j DROP"
        print(rule)
        #print(num)
        #num += 1
