#----------

# This Bash script is used to write down rules into iptables within a VM, which acts as server. As a parameter, it takes the variable NUM, which is the number for one of the rule sets that it to be used in testing.

#----------

NUM=${1} # Which rule set.

# Perform a while loop, reading each line of rules from output:
python3 p${NUM}.py | while read line; do
    iptables $line
done

# Load the rules into iptables:
iptables -L -v -n > rulesN_r${NUM}.1
