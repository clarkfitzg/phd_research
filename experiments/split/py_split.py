#!/usr/bin/env python3

import csv
import itertools
import operator

datadir = "/home/clark/data/pems/experiment_station/"

fname = "/home/clark/data/pems/threecolumns_sorted.csv"

def write_group(filename, rows, dd = datadir):
    full_filename = dd + filename
    with open(full_filename, "w") as g:
        writer = csv.writer(g)
        writer.writerows(rows)


f = open(fname)
reader = csv.reader(f)
grouped = itertools.groupby(reader, lambda x: x[0])
for grp in grouped:
    write_group(*grp)

close(f)

