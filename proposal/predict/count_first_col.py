#!/usr/bin/env python

"""
Takes about 4 minutes for 1 billion lines of /ssd/clarkf/Y.csv
"""

from __future__ import print_function
import csv


def column(datafile, column = 0):
    """
    Generator over the values for one column of a CSV file
    """
    with open(datafile) as f:
        lines = csv.reader(f)
        for row in lines:
            yield row[column]


def main(datafile):
    """
    Count the number of unique values in the first column of a csv file
    """
    first = column(datafile)
    seen = set(first)
    n = len(seen)
    print(n)


if __name__ == "__main__":
    import sys
    datafile = sys.argv[1]
    main(datafile)
