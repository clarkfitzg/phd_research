#!/usr/bin/env python

# Following
# https://stackoverflow.com/questions/33470603/hive-python-udf-gives-hive-runtime-error-while-closing-operators


from __future__ import print_function
import sys

try:
    # Will fail for large table
    tbl = sys.stdin.read()
    raise ValueError("Python error dude!")
except:
    print(sys.exc_info())
