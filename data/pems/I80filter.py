"""
Mon Oct 17 11:33:38 PDT 2016

Script to filter the huge amount of PeMS data into just those detectors on
I80 around Davis, CA.
"""

import gzip


fname = "/home/clark/data/pems/d04_text_station_raw_2016_04_13.txt.gz"

with open("davis_80_station_ids.csv") as f:
    station_ids = set(x.strip() for x in f)


def lines(gzfile, pattern_set=station_ids):
    """
    Generate the lines matching the pattern_set
    """
    with gzip.open(gzfile, mode="rt") as f:
        for line in f:
            station = line.split(",")[1]
            if station in pattern_set:
                yield line



I80_fname = "~/data/pems/I80_davis.txt.gz"
with gzip.open(I80_fname, mode="at") as f:
    addfile(fname)
