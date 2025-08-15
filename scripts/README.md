## Scripts

The directory "scripts" consists of Bash and python scripts that are used to perform tests on the network performance for various test cases such as using Netfilter (iptables/nftables), pcn-iptables (in a virtual machine), and XDP ACL. 

Each test consists of three Bash scripts; the first being used to load the rules into the table, the second is used to assign the CPU cores to network namespaces ns1 and nds2, acting as server and client respectively. The third script then performs the test itself, using nginx and wrk to simulate requests from 4 clients put the server under load. Python scripts are used to read the rules from the files and express them in the required format for the tables.

There are two main test-cases, positive and negative. Positive involves simply using wrk to stress the network stack. Negative test-case involves running wrk along with pcap, to generate "malicious" traffic to simulate a DDoS attack on the server.

Positive test-case scripts are test_ip.sh, test_xdp.sh, test_pcn.sh, test_xdp_mod.sh, test_ip_mod.sh, with the first two are used for Netfilter and XDP ACL with original rules, while the other three use the modified rules. Scripts test_irq.sh and test_prf.sh assign irqs to the cores and perform the test itself respectively for Netfilter and XDP ACL.
For pcn, there are separate scripts; tpcn_irq.sh and tpcn_pf.sh that access the virtual machine.

Scripts irqaft.sh, netflt.sh, nginx_kill.sh, nginx_start.sh, nginx_vm_setup.sh, perfcp.sh, perf_get.sh, servirq.sh, and xdp.sh are scripts used for testing with pcn-iptables, in which a virtual machine acts as the server. This scripts must be stored within the virtual machine and executed using ssh command. Scripts testrX.sh and pX_xdp.py are used to load rules into pcn-iptables and thus must be located on VM as well.

For negative test-cases, the first script for each test-case summons a pcap file required for the given rule-set. It is then used in the third script. Scripts for negative test-case end with "_pc.sh"; txdp_mod_pc.sh (XDP ACL for modified rules), txp_pc.sh, tip_mod_pc.sh, tip_pc.sh, with the scripts for irq assignment and testing are tpc_irq.sh and ts_pcap.sh.
For pcn-iptables, the scripts are tpcn_pc.sh and tpcn_pcap.sh, the script for irq assignment is the same.


