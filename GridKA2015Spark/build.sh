#!/bin/sh
VAR_VMX_FILE=/Volumes/MyExternalDrive/VMstore/TEMPLATES/cloudera-quickstart-vm-5.4.0-0-virtualbox/cloudera-quickstart-vm-5.4.0-0-virtualbox.ovf \
VAR_OUT_DIR=./cloudera-cdh-cluster-GRIDKA2015_vb_rev_1b \
VAR_TESTING_DIR=testing \
./packer build ./v7_from_QSVM/QSVM-UDI-FINAL.v2-vb.json

