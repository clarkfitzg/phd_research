"""
The filtered PeMS Davis I80 data is still too large for the visualizations
I was hoping to do. So instead I'll aggregate it.
"""

import pandas as pd

from pems import read_station_raw


datadir = "/scratch/clarkf/pems/I80_davis/"

# Reading this on Poisson takes 68 seconds
I80 = read_station_raw(datadir + "I80_davis.txt")

# Some derived columns
# Takes a few minutes
I80["timestamp"] = pd.to_datetime(I80["timestamp"],
        infer_datetime_format=True)

I80["weekday"] = I80["timestamp"].dt.dayofweek
I80["hour"] = I80["timestamp"].dt.hour
I80["minute"] = I80["timestamp"].dt.minute

I80["second"] = I80["timestamp"].dt.second

secs = I80["second"].value_counts()
# This shows that the natural way to separate is into groups
# TODO
# {0, 1, 

# 5 is the max number of lanes.
# nullcols = I80.isnull().all(axis=0)

I80["totalflow"] = (I80[["flow" + str(1 + i) for i in range(8)]]
                    .sum(axis=1, skipna=True))

station_summary = pd.DataFrame({
        "maxflows": I80["totalflow"].groupby(I80["ID"]).max()
        })

# Likely more useful...
station_summary["flow99"] = I80["totalflow"].groupby(I80["ID"]).quantile(0.99)

I
