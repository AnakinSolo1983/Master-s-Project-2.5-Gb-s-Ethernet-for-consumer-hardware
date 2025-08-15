#----------

# This is one of the python scripts used reads a configuration file containing network rules and generates corresponding iptables rules. The script processes each line of the file, extracts relevant information, and formats it into a command that can be executed in a Linux environment to manage network traffic. In this case, it accesses the 516 rules from the third rule-set.

#----------

# Read the file with rules:
with open('classbench-ng/rules.3', 'r') as file:

    # Extract the necessary fields of every rule:
    for line in file:
        parts = line.strip().split('\t')
        source = parts[0][1:]  # Remove the '@'
        dest = parts[1]
        source_ports = parts[2].replace(' : ', ':')
        dest_ports = parts[3].replace(' : ', ':')
        
        # Generate iptables rule
        rule = f"-A INPUT -s {source} -d {dest} -p tcp --sport {source_ports} --dport {dest_ports} -j DROP"
        print(rule)
