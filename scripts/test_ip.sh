#!/bin/bash -x

#----------

# This Bash script manages creates and deletes iptables rules within the network namespace ns1, while also monitoring their usage and storing observed statistics.

#----------

RSF=${1} # Directory for the data.
NUM=${2} # Which set of rules to test.

RSF=host/run${RSF} # the path to where the data will be stored.

# Remove all files in RSF:
rm -rf ${RSF}/*

# Create the directory if it doesn't exist yet:
mkdir -p ${RSF}

rule_count=$(ip netns exec ns1 sudo iptables -L -n | grep -c '^[A-Z]') # Count the number of iptables rules for namespace ns1 before loading new rules.
before=$(cat /proc/meminfo | grep 'MemAvailable') # Check the available memory before loading new rules.

echo "Number of iptables rules: $rule_count"

# Run the python script to load new rules into the iptables:
python3 p${NUM}.py | while read line; do
    ip netns exec ns1 iptables $line # Each line of output is a rule that needs to be added.
done

# Check the memory available after loading:
after=$(cat /proc/meminfo | grep 'MemAvailable')

# Observing the state of iptables before testing:
echo "Checking before:"; >> ${RSF}/ipcheck.out 2>1
ip netns exec ns1 sudo iptables -L -v -n >> netflt/run${RSF}/ipcheck.out 2>1

echo " "; >> ${RSF}/ipstat.out 2>1
echo "-----"; >> ${RSF}/ipstat.out 2>1
echo " "; >> ${RSF}/ipstat.out 2>1

sudo iptables -L INPUT

# Proceed to the Bash script which manages network interrupts:
/bin/bash -x test_irq.sh ${RSF} 20

echo " "; >> ${RSF}/ipstat.out 2>1
echo "-----"; >> ${RSF}/ipstat.out 2>1
echo " "; >> ${RSF}/ipstat.out 2>1

# Check iptables rules:
ip netns exec ns1 sudo iptables -L -v -n >> netflt/run${RSF}/ipstat.out 2>1

echo "----------"; >> ${RSF}/ipstat.out 2>1

# Print statistics for dropped packets:
echo "Dropped packets:" >> ${RSF}/ipstat.out 2>1
ip netns exec ns1 sudo iptables -L -v -n | grep "DROP"

ip netns exec ns1 sudo iptables -L -v -n | grep "DROP" >> ${RSF}/ipstat.out 2>1

echo " "; >> ${RSF}/ipstat.out 2>1

# Count the number of iptables rules after testing:
rule_count=$(ip netns exec ns1 sudo iptables -L -n | grep -c '^[A-Z]')
echo "Number of iptables rules: $rule_count"

# Extract information on the memory available before and after:
before_val=$(echo $before | awk '{print $2}')
after_val=$(echo $after | awk '{print $2}')
unit=$(echo $before | awk '{print $3}')

echo "Memory available before: $before_val $unit"
echo "Memory available after: $after_val $unit"

musage=$((before_val-after_val))
echo "Memory usage: $musage $unit"

# Deleting rules from iptables after usage:
echo "Deleting rules:"; >> ${RSF}/ipstat.out 2>1
ip netns exec ns1 sudo iptables -F INPUT >> ${RSF}/ipstat.out 2>1

ip netns exec ns1 sudo iptables -F INPUT

#sudo apt install iptables-persistent

echo " "; >> ${RSF}/ipstat.out 2>1
echo "-----"; >> ${RSF}/ipstat.out 2>1
echo " "; >> ${RSF}/ipstat.out 2>1

# Check that iptables is indeed clean:
echo "Checking:"; >> ${RSF}/ipcheck.out 2>1
ip netns exec ns1 sudo iptables -L -v -n >> ${RSF}/ipcheck.out 2>1
