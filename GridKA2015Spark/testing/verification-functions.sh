#!/bin/bash

# Bash functions for verifying expected aspects of a newly-created
# CentOS-based virtual machines used in training class; for example, 
# to ensure that we have a given amount of RAM or free disk space, 
# that certain packages are installed, that certain commands are in
# the path, and so on).  This is meant to be sourced into another 
# shell script that calls these functions with arguments that check 
# whatever is appropriate for that VM.


NUM_TESTS=0
NUM_ERRORS=0

verify_xml_config() {
	# NOTE: shell metacharacters must be escaped, so if you want to search for
	# a value of *, you need to pass '*' as $3
	
	XML_PATH=$1
	ELEM_NAME=$2
	EXPECTED_VALUE=$3
	
	if [ -z "$XML_PATH" -o -z "$ELEM_NAME" -o -z "$EXPECTED_VALUE" ]; then
		echo '### FATAL: verify_xml_config invoked incorrectly ###'
		exit 999
	fi
	
	FUNCTIONS_BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	PYTHON_CMD="python $FUNCTIONS_BASE_DIR/hadoop-config-parser.py"

	$PYTHON_CMD "$XML_PATH" "$ELEM_NAME" "$EXPECTED_VALUE" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		log_error "Validation of element '$ELEM_NAME' in '$XML_PATH' failed"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_listen_on_tcp_port() {
	TCP_PORT=$1

	if [ -z "$TCP_PORT" ]; then
		echo '### FATAL: verify_listen_on_tcp_port invoked incorrectly ###'
		exit 999
	fi

	netstat -tnl | perl -ne 'print /^\S+\s+\d+\s+\d+\s+(\S+)\s.*$/,"\n"' | grep ":${TCP_PORT}$" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		log_error "VM is NOT listening on TCP port '$TCP_PORT'"
	fi
	
	NUM_TESTS=$((NUM_TESTS+1))
}

verify_process_running() {
	PROC_NAME=$1
	
	if [ -z "$PROC_NAME" ]; then
		echo '### FATAL: verify_process_running invoked incorrectly ###'
		exit 999
	fi

	pgrep "$PROC_NAME" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		log_error "Process '$PROC_NAME' IS NOT running"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_process_not_running() {
	NPROC_NAME=$1
	
	if [ -z "$NPROC_NAME" ]; then
		echo '### FATAL: verify_process_not_running invoked incorrectly ###'
		exit 999
	fi	

	pgrep "$NPROC_NAME" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		log_error "Process '$NPROC_NAME' IS running"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_service_running() {
	SVC_NAME=$1
	
	if [ -z "$SVC_NAME" ]; then
		echo '### FATAL: verify_service_running invoked incorrectly ###'
		exit 999
	fi

	/sbin/service "$SVC_NAME" status 2> /dev/null | egrep '^running$|is running' > /dev/null
	if [ $? -ne 0 ]; then
		log_error "Service '$SVC_NAME' IS NOT running"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_service_not_running() {
	NSVC_NAME=$1

	if [ -z "$NSVC_NAME" ]; then
		echo '### FATAL: verify_service_not_running invoked incorrectly ###'
		exit 999
	fi

	/sbin/service "$SVC_NAME" status 2> /dev/null | egrep '^running$|is running' > /dev/null
	if [ $? -eq 0 ]; then
		log_error "Service '$NSVC_NAME' IS running"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_package_installed() {
	PKG_NAME=$1

	if [ -z "$PKG_NAME" ]; then
		echo '### FATAL: verify_package_installed invoked incorrectly ###'
		exit 999
	fi
	
	rpm -qi "$PKG_NAME" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		log_error "Package '$PKG_NAME' IS NOT installed"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_package_not_installed() {
	NPKG_NAME=$1
	
	if [ -z "$NPKG_NAME" ]; then
		echo '### FATAL: verify_package_not_installed invoked incorrectly ###'
		exit 999
	fi

	rpm -qi "$NPKG_NAME" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		log_error "Package '$NPKG_NAME' IS installed"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_command_in_path() {
	# NOTE: The test may fail if bash was not invoked as a login 
	# shell (bash -l), since it otherwise might not read the 
	# /etc/profile like the shell the actual user starts would
	CMD_NAME=$1
	
	if [ -z "$CMD_NAME" ]; then
		echo '### FATAL: verify_command_in_path invoked incorrectly ###'
		exit 999
	fi

	which "$CMD_NAME" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		log_error "No command '$CMD_NAME' in PATH"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_file_exists() {
	FILE_NAME=$1
	
	if [ -z "$FILE_NAME" ]; then
		echo '### FATAL: verify_file_exists invoked incorrectly ###'
		exit 999
	fi

	if [ ! -f "$FILE_NAME" ]; then
		log_error "File '$FILE_NAME' was expected but does not exist"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_dir_exists() {
	DIR_NAME=$1
	
	if [ -z "$DIR_NAME" ]; then
		echo '### FATAL: verify_dir_exists invoked incorrectly ###'
		exit 999
	fi

	if [ ! -d "$DIR_NAME" ]; then
		log_error "Directory '$DIR_NAME' was expected but does not exist"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_hdfs_path_exists() {
	OBJ_PATH=$1
	
	if [ -z "$OBJ_PATH" ]; then
		echo '### FATAL: verify_hdfs_path_exists invoked incorrectly ###'
		exit 999
	fi

	hadoop fs -ls "$OBJ_PATH" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		log_error "No object exists in HDFS at '$OBJ_PATH'"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

# TODO: Create a similar function to verify record count in MySQL

# NOTE that Hive is very slow, so running this test takes several seconds
verify_hive_table_record_count() {
	TABLE_NAME=$1
	EXPECTED_COUNT=$2

	if [ -z "$TABLE_NAME" -o -z "$EXPECTED_COUNT" ]; then
		echo '### FATAL: verify_hive_table_record_count invoked incorrectly ###'
		exit 999
	fi

	RCOUNT=`hive -S -e "select count(*) from $TABLE_NAME" | egrep '^[0-9]+$'` >/dev/null 2>&1
	if [ $? -ne 0 -o "$RCOUNT" != "$EXPECTED_COUNT" ]; then
		log_error "Validation of Hive table $TABLE_NAME failed"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_impala_table_record_count() {
	TABLE_NAME=$1
	EXPECTED_COUNT=$2

	if [ -z "$TABLE_NAME" -o -z "$EXPECTED_COUNT" ]; then
		echo '### FATAL: verify_impala_table_record_count invoked incorrectly ###'
		exit 999
	fi

	impala-shell --quiet -q "SELECT COUNT(*) AS mycount FROM $TABLE_NAME" | grep "\| $EXPECTED_COUNT " >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		log_error "Validation of Impala table $TABLE_NAME failed"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}


verify_min_free_disk_space_kb() {
	FILESYSTEM=$1
	EXPECTED_FREE_KB=$2
	
	if [ -z "$FILESYSTEM" -o -z "$EXPECTED_FREE_KB" ]; then
		echo '### FATAL: verify_min_free_disk_space_kb invoked incorrectly ###'
		exit 999
	fi

	FREE_KB=`df | grep /dev/sda1 | perl -ne 'print /^\S+\s+\S+\s+\S+\s+(\d+)\s/'`
	if [ $FREE_KB -lt $EXPECTED_FREE_KB ]; then
		log_error "Insufficient free disk space on $FILESYSTEM"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_swap() {
	EXPECTED_SWAP_SIZE=$1
	
	if [ -z "$EXPECTED_SWAP_SIZE" ]; then
		echo '### FATAL: verify_swap invoked incorrectly ###'
		exit 999
	fi

	TOTAL_SWAP=`free | perl -ne 'print /^Swap:\s+(\d+)\s/'`
	if [ $TOTAL_SWAP -ne $EXPECTED_SWAP_SIZE ]; then
		log_error "Incorrect swap space on the VM ($TOTAL_SWAP != $EXPECTED_SWAP_SIZE)"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_ram() {
	EXPECTED_RAM_SIZE=$1
	
	if [ -z "$EXPECTED_RAM_SIZE" ]; then
		echo '### FATAL: verify_ram invoked incorrectly ###'
		exit 999
	fi

	TOTAL_RAM=`free | perl -ne 'print /^Mem:\s+(\d+)\s/'`
	if [ $TOTAL_RAM -ne $EXPECTED_RAM_SIZE ]; then
		log_error "Incorrect amount of RAM allocated to the VM ($TOTAL_RAM != $EXPECTED_RAM_SIZE)"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_cdh_version() {
	EXPECTED_CDH_VERSION=$1
	
	if [ -z "$EXPECTED_CDH_VERSION" ]; then
		echo '### FATAL: verify_cdh_version invoked incorrectly ###'
		exit 999
	fi

	CDH_VERSION=`hadoop version | grep '^Hadoop ' | perl -ne 'print /-cdh(\d\.\d\.\d)/'`
	if [ "$CDH_VERSION" != "$EXPECTED_CDH_VERSION" ]; then
		log_error "Wrong CDH version installed ($CDH_VERSION != $EXPECTED_CDH_VERSION)"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_java_version() {
	EXPECTED_JAVA_VERSION=$1
	
	if [ -z "$EXPECTED_JAVA_VERSION" ]; then
		echo '### FATAL: verify_java_version invoked incorrectly ###'
		exit 999
	fi

	JAVA_VERSION=`java -version 2>&1 | grep "^java version" | cut -d'"' -f2`
	if [ "$JAVA_VERSION" != "$EXPECTED_JAVA_VERSION" ]; then
		log_error "Wrong Java version in PATH ($JAVA_VERSION != $EXPECTED_JAVA_VERSION)"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_python_version() {
	EXPECTED_PYTHON_VERSION=$1
	
	if [ -z "$EXPECTED_PYTHON_VERSION" ]; then
		echo '### FATAL: verify_python_version invoked incorrectly ###'
		exit 999
	fi
	
	PYTHON_VERSION=`python -V 2>&1 | perl -ne 'print /^Python\s+([0-9\.]+)/'`
	if [ "$PYTHON_VERSION" != "$EXPECTED_PYTHON_VERSION" ]; then
		log_error "Wrong Python version in PATH ($PYTHON_VERSION != $EXPECTED_PYTHON_VERSION)"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_selinux_disabled() {
	grep 'SELINUX=disabled' /etc/selinux/config >/dev/null 2>&1
	if [ $? -ne 0 ] ; then
		log_error "SELinux DOES NOT appear to be disabled"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

verify_sudo() {
	sudo -n id | grep 'uid=0(root)' > /dev/null 2>&1
	if [ $? -ne 0 ] ; then
		log_error "Passwordless sudo DOES NOT appear to be set up for $USER"
	fi

	NUM_TESTS=$((NUM_TESTS+1))
}

log_error() {
	# indent slightly to be subordinate to message about the
	# component we are currently examining
	echo "  ERROR: $1"

	# Increment this counter, which the parent script can check.
	# If non-zero, then the parent script should exit with a 
	# non-zero status code
	NUM_ERRORS=$((NUM_ERRORS+1))
}
