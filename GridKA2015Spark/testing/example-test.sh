#!/bin/bash

# This script runs various tests in order to nominally verify
# that a virtual machine with CDH is configured and working
# as expected. 
#
# This script needs to be run as the user that we expect
# students/customers to use (i.e. 'training' for the
# training VMs or 'cloudera' for the demo VMs), as this is
# needed for the sudo check.

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $BASE_DIR/verification-functions.sh

# Basic checks of the VM itself
verify_selinux_disabled
verify_min_free_disk_space_kb /dev/sda1 8388608
verify_ram 2054720
verify_swap 1999992


# Validate versions of important software
verify_cdh_version 4.5.0
verify_java_version 1.7.0_21
verify_python_version 2.6.6

# Ensure these essential packages are installed
verify_package_installed dejavu-sans-fonts
verify_package_installed dejavu-sans-mono-fonts
verify_package_installed emacs  
verify_package_installed evince 
verify_package_installed gcc    
verify_package_installed gedit  
verify_package_installed git    
verify_package_installed liberation-mono-fonts
verify_package_installed make 
verify_package_installed R      
verify_package_installed rsync  
verify_package_installed screen 
verify_package_installed telnet 
verify_package_installed tomcat6
verify_package_installed vim-enhanced
verify_package_installed vim-X11

# These should not be installed
verify_package_not_installed ivtv-firmware

# These commands must be in the path
verify_command_in_path hadoop
verify_command_in_path java
verify_command_in_path javac
verify_command_in_path jps
verify_command_in_path mvn
verify_command_in_path vi


# Checking these ensures at least a basic GNOME setup
verify_process_running metacity
verify_process_running gnome-panel

# And we should not have these processes running in a new VM
verify_process_not_running firefox

# We need these services running
verify_service_running atd
verify_service_running zookeeper-server

# And these services should NOT be running
verify_service_not_running iptables
verify_service_not_running ip6tables

# Verify specific names and values in a Hadoop-style XML config file
verify_xml_config /etc/hadoop/conf/hdfs-site.xml dfs.webhdfs.enabled true

# Ensure this item exists in HDFS
verify_hdfs_path_exists /user/training

verify_hive_table_record_count foox 4


# this should always be the last thing in the script
if [ $NUM_ERRORS -eq 0 ]; then
    echo "All $NUM_TESTS tests pass"
    exit 0
else
    echo ""
    echo "###########################################################"
    echo "##                                                       ##"
    echo "## FAILURE: $NUM_ERRORS of the tests performed on this VM have     ##"
    echo "##          failed. You should investigate and either    ##"
    echo "##          fix the problem or update the tests to       ##"
    echo "##          accurately reflect what you want to verify.  ##"
    echo "##                                                       ##"
    echo "###########################################################"
    echo ""
    exit 1
fi

