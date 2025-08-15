#----------

# This is one of the python scripts used in VM that reads a configuration file containing network rules and generates corresponding rules. The script processes each line of the file, extracts relevant information, and formats it into a command that can be executed in a Linux environment to manage network traffic. In this case, it accesses rules from the rule-set given by the parameter NUM. By analyzing a set of rules defined in a file, the script determines which rules should be applied and outputs them in a format suitable for use. Here, it accesses the third rule-set.

#----------

from ipaddress import IPv4Address, IPv4Network

# Read the file with rules:
with open('../classbench-ng/rules.3', 'r') as file:

    # Extract the necessary fields of every rule:
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
                        continue # Skipping rules that do not meet this criteria.
        
        
        # Generate iptables rule:
        rule = f"-A INPUT -s {source} -d {dest} -p tcp --sport {source_ports} --dport {dest_ports} -j DROP"
        print(rule)
