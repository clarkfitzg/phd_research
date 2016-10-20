#!/usr/bin/env python

"""
Mon Oct 17 11:33:38 PDT 2016

Script to filter the huge amount of PeMS data into just those detectors on
I80 around Davis, CA.
"""

import os
import gzip


with open("davis_80_station_ids.csv") as f:
    station_ids = set(x.strip() for x in f)


def matchlines(gzfile, pattern_set=station_ids):
    """
    Generate the lines matching the pattern_set
    """
    with gzip.open(gzfile, mode="rt") as f:
        for line in f:
            # Data format is
            # timestamp, station ID, ...
            station = line.split(",")[1]
            if station in pattern_set:
                yield line


def main(args):

    fnames = (os.sep.join((args.datadir, x)) for x in os.listdir(args.datadir)
                if x.endswith(".txt.gz"))

    with gzip.open(args.outfile, mode="at") as outfile:
        for f in fnames:
            for l in matchlines(f):
                outfile.write(l)


# sanity check - works!
#I80 = read_station_raw(I80_fname)
#I80["ID"].value_counts()

if __name__ == "__main__":

    import argparse
    parser = argparse.ArgumentParser()

    parser.add_argument("--datadir", default="/scratch/clarkf/pems/district4/",
            help="Location of the raw station txt.gz files")

    parser.add_argument("--outfile",
            default="/scratch/clarkf/pems/I80_davis.txt.gz",
            help="File to append all matching rows to")

    args = parser.parse_args()

    main(args)
