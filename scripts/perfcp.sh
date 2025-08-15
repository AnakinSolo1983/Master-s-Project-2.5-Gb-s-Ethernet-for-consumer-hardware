#!/bin/bash -x

#----------

# This Bash script handles file permissions for the perf data file stored in the VM, so that a copy of it can be transferred to the main machine, where the rest of the data for the test is stored.

#----------

RSF=${1} # Path to where data is stored.

# List detailed information about the perf.data file before permission change:
ls -l /home/olegvm/${RSF}/perf.data

# Change the permissions of the perf.data file to read and write for the owner, and read for group and others:
chmod 644 /home/olegvm/${RSF}/perf.data

# List detailed information about the perf.data file after permission change:
ls -l /home/olegvm/${RSF}/perf.data
