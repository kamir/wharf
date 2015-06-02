#!/bin/bash		

# Final cleanup to reduce size of the VM image we distribute
# NOTE: When initially building an image, you may wish to 
# *not* run this script at first so you will have a chance
# to inspect the logs inside the VM. 

# TODO: Shut down ALL unneeded services here, to minimize
# any logs, cache, or PID files we include in the VM.

sleep 10
sync

# We don't need the repo for OS packages anymore (we didn't 
# have them on the VMs built with Boxgrinder, either, as 
# they were ephemeral)
rm -f /etc/yum.repos.d/CentOS-*
rm -f /etc/yum.repos.d/EPEL.repo

# Since we delete the local package directory, we need to remove
# the corresponding local yum repos (if there were any
rm -f /etc/yum.repos.d/Cloudera-*-local.repo

# Clean package cache
yum clean all

# remove any history
history -c

# remove the temp files (includes any leftover deployments and 
# files such as local yum repo mirrors)
rm -rf /tmp/*
rm -rf /var/tmp/*

# remove logs
find /var/log -type f -exec rm {} \;

# Clean up unused disk space so compressed image is smaller.
cat /dev/zero > /tmp/zero.fill
rm /tmp/zero.fill
sync

# clean up redhat interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules
if [ -r /etc/sysconfig/network-scripts/ifcfg-eth0 ]; then
	sed -i 's/^HWADDR.*$//' /etc/sysconfig/network-scripts/ifcfg-eth0
	sed -i 's/^UUID.*$//' /etc/sysconfig/network-scripts/ifcfg-eth0
fi
