with open('dts/dep/test-acl-input/acl1v4_10k_rule', 'r') as file:
    for line in file:
        parts = line.strip().split('\t')
        source = parts[0][1:]  # Remove the '@'
        dest = parts[1]
        source_ports = parts[2].replace(' : ', ':')
        dest_ports = parts[3].replace(' : ', ':')
        
        # Generate iptables rule
        #rule = f"iptables -A INPUT -s {source} -d {dest} -p tcp --sport {source_ports} --dport {dest_ports} -j ACCEPT"
        rule = f"-A INPUT -s {source} -d {dest} -p tcp --sport {source_ports} --dport {dest_ports} -j ACCEPT"
        print(rule)
