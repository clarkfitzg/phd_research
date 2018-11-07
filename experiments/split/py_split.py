import csv
import itertools
import operator

datadir = "/home/clark/data/pems/experiment_station/"

fname = "/home/clark/data/pems/threecolumns_sorted.csv"

with open(fname) as f:
    reader = csv.reader(f)
    grouped = itertools.groupby(reader, lambda x: x[0])
    for grp in grouped:
        grpfile = datadir + grp[0]
        with open(grpfile) as g:
            g.writelines(grp[1])
