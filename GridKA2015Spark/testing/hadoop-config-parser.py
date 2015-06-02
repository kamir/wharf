#!/usr/bin/env python

# Simple python script that can read the standard XML format
# used for Hadoop-related configuration files to check that 
# a specified key has the expected value. This is rather hard
# to do from a shell script

import sys
import xml.etree.ElementTree as ET

if len(sys.argv) != 4:
   print "ERROR: arg1: file_path, arg2: element_name, arg3: expected_value"
   exit(1)

file_path = sys.argv[1]
elem_name = sys.argv[2]
expected_value = sys.argv[3]

tree = ET.parse(file_path)
root = tree.getroot()

for child in root:
   name = child.find('name').text
   
   if name == elem_name:
      value = child.find('value').text

      if value == expected_value:
          exit(0)
      else:
          print "ERROR: Element '%s' had value '%s' instead of expected value '%s'" % (name, value, expected_value)
          exit(2)

print "No element named %s was found" % elem_name
exit(3)


   #print root.tag


