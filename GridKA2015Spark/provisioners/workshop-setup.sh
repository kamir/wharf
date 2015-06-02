#!/bin/bash		

# This script is intended for course-specific customizations that
# don't affect the configuration of the OS or Hadoop-related services 
# (those should go in extra-os-setup.sh or hadoop-install).
# Examples include unpacking local data files, uploading data to
# HDFS, inserting data into MySQL, and creating tables in Hive or 
# Impala.
#
# Ideally, whatever customizations are done here should have a 
# corresponding validation in the test-vm.sh script.

sudo yum -y install mc
sudo yum -y install subversion

cd workspace

# checkout the CumulsRDF project and Humulus
#svn checkout https://cumulusrdf.googlecode.com/svn/trunk/ cumulusrdf --username mirko.kaempf@cloudera.com
#git clone https://github.com/kamir/Humulus.git

# DEPLOY and build KITE SDK
#
# Needs some fixes in the VM
#
#    Java version 1.7 ...
#    run builds as sudo ...
#
git clone https://github.com/kamir/kite.git
git clone https://github.com/kamir/kite-docs.git

# DEPLOY the OKAPI and grafos.ml stuff
#git clone https://github.com/kamir/okapi.git
#git clone https://github.com/grighetto/giraph.git

# DEPLOY the graph-benchmarks ...
#git clone https://github.com/kamir/giraphl.git

# checkout Hadoop.TS
#git clone https://github.com/kamir/Hadoop.TS.git

# checkout Crunch.TS
#git clone https://github.com/kamir/crunch.TS.git

# checkout HDT (incubator)
git clone https://github.com/kamir/incubator-hdt.git

# checkout Gephi-Connector
git clone https://github.com/kamir/gephi-plugins-bootcamp.git
git clone https://github.com/kamir/gephi-plugins.git
git clone https://github.com/kamir/gephi.git
git clone https://github.com/kamir/ghc.git

# Install latest NetBeans
# 




#
# Install Jena and FUSEKI
#
#######################
#mkdir jena
#cd jena
#svn co https://svn.apache.org/repos/asf/jena/trunk

# fuseki-server --update --mem /ds
