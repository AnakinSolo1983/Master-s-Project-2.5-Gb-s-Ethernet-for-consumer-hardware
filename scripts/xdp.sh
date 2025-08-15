NUM=${1} # The rule set.
cd polycube
pwd
polycubed -d
pwd
pcn-iptables-init-xdp
pwd
/bin/bash -x testr${NUM}.sh

