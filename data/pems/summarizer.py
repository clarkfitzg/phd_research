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

# 5 is the max number of lanes.
# nullcols = I80.isnull().all(axis=0)

I80["totalflow"] = (I80[["flow" + str(1 + i) for i in range(8)]]
                    .sum(axis=1, skipna=True))
