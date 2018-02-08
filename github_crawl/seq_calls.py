#!/usr/bin/env python3
"""
Thu Feb  8 11:14:08 PST 2018

Print out files that have two sequences of strings
"""

import sys

_, string1, string2 = sys.argv

def check_file(fname):
    found_string1 = False
    try:
        with open(fname) as f:
            for line in f:
                if string1 in line:
                    found_string1 = True
                if string2 in line:
                    if found_string1:
                        print(fname)
                        break
    except UnicodeDecodeError:
        # Presumably binary files.
        pass

with open("rfiles.txt") as f:
    for fname in f:
        check_file(fname.strip())
