#----------

# This Bash script is used to setup polycube, in order to write down rules into pcn-iptables within a VM, which acts as server. As a parameter, it takes the variable NUM, which is the number for one of the rule sets that it to be used in testing.

#----------

NUM=${1}

# Go to polycube:
cd polycube

# Check that we are in polycube:
pwd
polycubed -d
pwd

#Initiate pcn-iptables:
pcn-iptables-init-xdp

# Execute script that writes down the rules into pcn-iptables:
/bin/bash -x testr${NUM}.sh

