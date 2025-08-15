#! /bin/bash

# to simplify user experience with XDP-ACL POC this script aims
# to automate cloning DPDK, applying the patch and building the binaries.

git clone -v https://dpdk.org/git/dpdk dpdk-acl-bpf
cd dpdk-acl-bpf

# select LTS version
git checkout v24.11

#apply patch
git am -3 ../patch/0001-acl-XDP-ACL-adoption-POC.patch

# build DPDK it might take some time
meson setup --prefix=${PWD}/x86_64-default-linuxapp-gcc-dbg-install --werror -Dbuildtype=debug -Dmachine=default x86_64-default-linuxapp-gcc-dbg
ninja -v -j 8 -C x86_64-default-linuxapp-gcc-dbg/

# compile XDP program
clang -O2 -g -Wall -target bpf -I./lib/acl/ -I./ -c app/acl-bpf/xdp_acl4.c -o app/acl-bpf/xdp_acl4.o


