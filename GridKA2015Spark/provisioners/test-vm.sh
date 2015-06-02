#!/bin/bash		

# Uses my framework to run sanity tests on VM. We make this 
# a provisioner that runs as the next-to-last step of the 
# build, so that the build fails if one of the tests fail.
# The VM should be rebooted just before running this script,
# so that we're properly testing the initial state on boot
# just like a student would experience.
# 
# 
# TODO: Also define/run tests against whatever gets added
# to install-datasets.sh, to show how we can check that 
# the prerequisites for exercises used in class are set up
# correctly. This will be important for custom classes!

# load the functions we use for testing. These are copied to 
# the /tmp directory in the VM by the file provisioner.
cd /tmp && source verification-functions.sh


# Basic checks of the VM itself
verify_selinux_disabled
#verify_min_free_disk_space_kb /dev/sda1 8388608
#verify_ram 3088948
#verify_swap 2047992


# Validate versions of important software
verify_cdh_version 4.7.0
verify_java_version 1.7.0_21
verify_python_version 2.6.6


# Verify presence of some file customizations we made worked
verify_file_exists /home/training/Desktop/Eclipse.desktop
verify_file_exists /home/training/Desktop/gnome-terminal.desktop
verify_file_exists /home/training/eclipse/eclipse
verify_file_exists /home/training/.impalahistory
verify_file_exists /home/training/.exrc
verify_file_exists /home/training/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.jdt.core.prefs


# Ensure these essential packages are installed
verify_package_installed bzip2
verify_package_installed chkconfig
verify_package_installed curl
verify_package_installed dejavu-sans-mono-fonts
verify_package_installed emacs
verify_package_installed evince
verify_package_installed file-roller
verify_package_installed firefox
verify_package_installed gcc    
verify_package_installed gedit  
verify_package_installed gedit-plugins
verify_package_installed git
verify_package_installed gnome-terminal
verify_package_installed gnome-user-docs
verify_package_installed gzip
verify_package_installed liberation-mono-fonts
verify_package_installed man-pages
verify_package_installed nano
verify_package_installed nc
verify_package_installed ntp
verify_package_installed openssh
verify_package_installed python
verify_package_installed ruby
verify_package_installed screen
verify_package_installed vim-enhanced
verify_package_installed yelp


# Verify installation of important hadoop-related packages
verify_package_installed flume-ng
verify_package_installed hadoop-mapreduce
verify_package_installed hcatalog
verify_package_installed hive
verify_package_installed hue-common
verify_package_installed impala
verify_package_installed mahout
verify_package_installed oozie
verify_package_installed parquet
verify_package_installed pig
verify_package_installed search
verify_package_installed solr
verify_package_installed sqoop
verify_package_installed zookeeper


# Make sure daemons are bound to ports as expected
# TODO: add tests for HS2 and Impala
verify_listen_on_tcp_port 22		# SSH
verify_listen_on_tcp_port 3306      # MySQL
verify_listen_on_tcp_port 8020      # Hadoop NameNode
verify_listen_on_tcp_port 8021      # Hadoop JobTracker
verify_listen_on_tcp_port 8888      # Hue
verify_listen_on_tcp_port 8983      # Solr
verify_listen_on_tcp_port 9083      # Hive metastore (Thrift)
verify_listen_on_tcp_port 11000     # Oozie
#verify_listen_on_tcp_port 22000     # Impala
verify_listen_on_tcp_port 50030		# Hadoop JobTracker Web UI
verify_listen_on_tcp_port 50070		# Hadoop NameNode Web UI



# These commands must be in the path
verify_command_in_path emacs
verify_command_in_path hadoop
verify_command_in_path java
verify_command_in_path javac
verify_command_in_path jps
verify_command_in_path mvn
verify_command_in_path ssh
verify_command_in_path vi


# Checking these ensures at least a basic GNOME setup
#verify_process_running metacity
#verify_process_running gnome-panel


# These services should NOT be running
verify_service_not_running flume-ng-agent
verify_service_not_running iptables


# These services should be running
verify_service_running atd
verify_service_running hadoop-0.20-mapreduce-jobtracker
verify_service_running hadoop-0.20-mapreduce-tasktracker
verify_service_running hadoop-hdfs-namenode
verify_service_running hadoop-hdfs-datanode
verify_service_running impala-server
verify_service_running impala-catalog
verify_service_running impala-state-store
verify_service_running hive-server2
verify_service_running hive-metastore
verify_service_running hue
verify_service_running oozie
verify_service_running sshd
verify_service_running solr-server
#verify_service_running vmware-tools 
verify_service_running zookeeper-server


# Verify important aspects of Hadoop / Hive / Impala configuration
verify_xml_config /etc/hadoop/conf/core-site.xml fs.defaultFS hdfs://localhost.localdomain:8020/
verify_xml_config /etc/hadoop/conf/core-site.xml hadoop.proxyuser.hue.hosts '*'
verify_xml_config /etc/hadoop/conf/core-site.xml hadoop.proxyuser.hue.groups '*'

verify_xml_config /etc/hadoop/conf/mapred-site.xml mapred.job.tracker localhost.localdomain:8021

verify_xml_config /etc/hadoop/conf/hdfs-site.xml dfs.replication 1
verify_xml_config /etc/hadoop/conf/hdfs-site.xml dfs.datanode.hdfs-blocks-metadata.enabled true
verify_xml_config /etc/hadoop/conf/hdfs-site.xml dfs.client.file-block-storage-locations.timeout 10000
verify_xml_config /etc/hadoop/conf/hdfs-site.xml dfs.client.read.shortcircuit true
verify_xml_config /etc/hadoop/conf/hdfs-site.xml dfs.domain.socket.path /var/run/hadoop-hdfs/dn._PORT

verify_xml_config /etc/hive/conf/hive-site.xml hive.metastore.uris thrift://localhost.localdomain:9083

verify_xml_config /etc/impala/conf/hive-site.xml hive.metastore.uris thrift://localhost.localdomain:9083

verify_xml_config /etc/impala/conf/hdfs-site.xml dfs.datanode.hdfs-blocks-metadata.enabled true
verify_xml_config /etc/impala/conf/hdfs-site.xml dfs.client.read.shortcircuit true
verify_xml_config /etc/impala/conf/hdfs-site.xml dfs.client.file-block-storage-locations.timeout 10000



# Ensure some required directories exist in HDFS
verify_hdfs_path_exists /user/training
verify_hdfs_path_exists /user/hive/warehouse
verify_hdfs_path_exists /user/oozie/share/lib



# Do a live test on Hive and Impala
HIVE_DATA_FILE='/tmp/hive-test-data.csv'
cat <<-EOT > "$HIVE_DATA_FILE"
	1,Abe,Adelman
	2,Ben,Benson
	3,Cy,Carlson
EOT

HIVE_DDL_FILE='/tmp/hive-test.hql'
cat <<-EOT > "$HIVE_DDL_FILE"
	CREATE TABLE peopletest (id INT, fname STRING, lname STRING)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ",";

	LOAD DATA LOCAL INPATH '$HIVE_DATA_FILE' INTO TABLE peopletest;
EOT
hive -S -f "$HIVE_DDL_FILE"

hive -S -e 'SELECT COUNT(*) FROM peopletest'
verify_hive_table_record_count peopletest 3

impala-shell --quiet -q 'INVALIDATE METADATA' >/dev/null 2>&1
verify_impala_table_record_count peopletest 3
impala-shell -q 'DROP TABLE peopletest'


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