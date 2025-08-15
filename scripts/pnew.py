from ipaddress import IPv4Address, IPv4Network
import sys

outp = str(sys.argv[2]) + "_mod_rule"
print(outp)
with open(str(sys.argv[1]), 'r') as file:
	with open(outp, 'w') as output_file:
    		for line in file:
        		parts = line.strip().split('\t')
        		source = parts[0][1:]  # Remove the '@'
        		dest = parts[1]
        		source_ports = parts[2].replace(' : ', ':')
        		dest_ports = parts[3].replace(' : ', ':')
        		if IPv4Address('192.168.11.10') in IPv4Network(source) and IPv4Address('192.168.11.1') in IPv4Network(dest):
        			continue
        
        		if source == '0.0.0.0/0' and source == dest:
        			continue
        
        		val1,val2 = dest_ports.split(':')
        		if int(val1) != int(val2):
                		if int(val1) != 0 or int(val2) != 65535:
                	        	continue
        
        		output_file.write(line)
        # Generate iptables rule
        #rule = f"iptables -A INPUT -s {source} -d {dest} -p tcp --sport {source_ports} --dport {dest_ports} -j ACCEPT"
        #rule = f"-A INPUT -s {source} -d {dest} -p tcp --sport {source_ports} --dport {dest_ports} -j DROP"
        #"""
        #if source == '0.0.0.0/0' and source == dest:
        	#rule = f"-A INPUT -s {source} -d {dest} -p tcp --sport {source_ports} --dport {dest_ports} -j ACCEPT"
        #"""
        #print(rule)
