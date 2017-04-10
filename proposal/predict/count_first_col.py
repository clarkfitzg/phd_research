#!/usr/bin/env python

"""
$ time ./count_first_col.py /ssd/clarkf/Y.csv
616057 unique values in the first column.
4 were empty.

real    11m0.908s
user    10m43.298s
sys     0m17.163s

Verify counting the empty lines:

clarkf@fingers /ssd/clarkf
$ time grep '^$' Y.csv | wc
      4       0       4

real    1m14.859s
user    1m4.633s
sys     0m10.211s

Where are the empty lines? Well, this is exceedingly weird, given that I
wrote the program to write Y.csv. I certainly didn't expect these to show
up, especially in random places like this.

clarkf@fingers /ssd/clarkf
$ time grep -n '^$' Y.csv
329508121:
512431632:
580796919:
736004375:

real    1m22.331s


Compare this to just looping through in C and counting lines:

clarkf@fingers /ssd/clarkf
$ time wc -l Y.csv 
1000000000 Y.csv

real    0m19.107s
user    0m7.443s
sys     0m11.659s
"""

from __future__ import print_function
import csv


emptylines = 0


def column(datafile, column = 0):
    """
    Generator over the values for one column of a CSV file
    """
    global emptylines
    with open(datafile) as f:
        lines = csv.reader(f)
        for row in lines:
            try:
                yield row[column]
            except IndexError:
                emptylines += 1


def main(datafile):
    """
    Count the number of unique values in the first column of a csv file
    """
    first = column(datafile)
    seen = set(first)
    n = len(seen)
    print("{0} unique values in the first column.".format(n))
    print("{0} were empty.".format(emptylines))


if __name__ == "__main__":
    import sys
    datafile = sys.argv[1]
    main(datafile)
