This directory contains all information regarding XDP-ACL POC.
In particular, this README aims to explain how to build and use it.
- patch/ subdirectory contains the actual patch(es) that need to be applied
  on top of DPDK code-base.
- get_build.sh is a script to automate clone and build process.
- src/ contains copies of all source files I created and/or modified.
  It is not used in build process, and I put it here just for code reviewers
  convenience.
  
    The patch consists of three main parts:
    1) Changes in ACL library to open BPF MAPs and load generated ACL
       context (transisions and rules arrays) into the provide BPF MAPs.
    2) User-space program (dpdk-acl-bpf) that performs build of provided filter
       rules into ACL context and then uploads generated context into BPF MAPs.
       Note that dpdk-acl-bpf program is a reworked version of app/test-acl
       program provided by DPDK.
    3) XDP program that performs actual search over input packet’s data using
       filled by 2) BPF MAPs.

    how to try
    +++++++++++

    1) Get DPDK LTS (24.11) version and apply the patch:

    $ git clone -v  https://dpdk.org/git/dpdk dpdk-acl-bpf
    $ cd dpdk-acl-bpf
    $ git checkout v24.11
    $ git am -3 <this-patch-name>

    2) Build DPDK (it could take some time):

    $ meson setup --prefix=${PWD}/x86_64-default-linuxapp-gcc-dbg-install --werror -Dbuildtype=debug -Dmachine=default x86_64-default-linuxapp-gcc-dbg
    $ ninja -v -j 8 -C x86_64-default-linuxapp-gcc-dbg/

    3) Compile XDP program. Note that clang version 19 or higher is
       required. Previous clang versions might crash when trying to compile
       it:

    $ clang -O2 -g -Wall -target bpf -I./lib/acl/ -I./ -c app/acl-bpf/xdp_acl4.c -o app/acl-bpf/xdp_acl4.o

    4) Load compiled XDP program into the kernel, for NIC you plan to use it
       with. Then verify that it was loaded and get created BPF MAP IDs.

    $ sudo xdp-loader load -vv <your_NIC_device_name> ./app/acl-bpf/xdp_acl4.o

    $ bpftool map show
      ....
      1345: array  name acl_ctx  flags 0x0
            key 4B  value 1360B  max_entries 1  memlock 1680B
            btf_id 2083
      1346: array  name acl_trans  flags 0x0
            key 4B  value 8B  max_entries 4194304  memlock 33554752B
            btf_id 2083
      1347: array  name acl_rule  flags 0x0
            key 4B  value 48B  max_entries 65536  memlock 3146048B
            btf_id 2083

    5) Generate ACL context for filtering rules and uploaded generated
       context into XDP BPF MAPs. Note that user required to provide BPF MAP
       IDs in a specific order:
       --bpf="ID(acl_ctx):ID(acl_trans):ID(acl_rule)", in that particular
       case: --bpf="1345:1346:1347".
       Parameters before "--" are DPDK specific, and better be unmodified.
       For more information about them please refer to DPDK users guide.
       --rulesf - specifies file witht the input ruleset (in classbench-ng
         format.
       --rulenum - specifies max number of rules to load. I used to provide
         some big value, to make sure that all rules will be uploaded.

    $ sudo ./x86_64-default-linuxapp-gcc-dbg/app/dpdk-acl-bpf -n 1 --lcores='0' --no-pci --no-huge -- --rulesf=<your_input_rule_file> --rulenum=100000 --bpf="1345:1346:1347"

    Also 'dpdk-acl-bpf' for testing purposes allows user to perform search
    using uploaded BPF MAPs in user-space against provided classbench-ng
    trace file. As an example:

    $ sudo ./x86_64-default-linuxapp-gcc-dbg/app/dpdk-acl-bpf -n 1 --lcores='0' --no-pci --no-huge -- --rulesf=./test-acl-input/acl1v4_10k_rule --tracef=./test-acl-input/acl1v4_10k_trace --iter=1 --verbose=3 --rulenum=100000 --tracenum=100000 --bpf="1345:1346:1347"

    Will perform search for each input trace and print matching result.
    As an example, output line:
    ipv4_5tuple: 97850, category: 0, result: 5183
    means that for trace with ID '97850' matching rule ID is 5183.
    Input trace shall also contain expected mathcing rule and these IDs
    should be identical:
    $cat -n ./dts/dep/test-acl-input/acl1v4_10k_trace | grep 97850
     97850  3869543598      601217244       65535   61009   6       0       5183

    6) At that point BPF MAP contents should be loaded, and XDP ACL program
       should be ready for action. For the NIC it installed on, it should
       intercept and drop all packets that match any of the provided rule,
       while the rest of the traffic should remain intact. Note that each
       acl_rule has an atomic counter for matched (dropped) packets.
       User can examine its value with 'bpftool map lookup' command.
       Let say to examine rule with ID 5183 (note that lookup accepts key as
       an array of bytes, starting from less significant one):

    $ sudo bpftool map lookup name acl_rule key 63 20 00 00
    {
        "key": 5183,
        "value": {
            "id": 5183,
            "action": "XDP_DROP",
            "rule": {
                "proto": 6,
                "proto_mask": 255,
                "ip_src": 3869543584,
                "ip_src_mask_len": 32,
                "ip_dst": 601217244,
                "ip_dst_mask_len": 32,
                "port_src_low": 0,
                "port_src_high": 65535,
                "port_dst_low": 61000,
                "port_dst_high": 61009
            },
            "num_packet": 13
        }
    }
