"""
The filtered PeMS Davis I80 data is still too large for the visualizations
I was hoping to do. So instead I'll aggregate it.
"""

import pandas as pd

from pems import read_station_raw


datadir = "/scratch/clarkf/pems/I80_davis/"

# Reading this on Poisson takes 68 seconds
I80 = read_station_raw(datadir + "I80_davis.txt")

# 5 is the max number of lanes.
nullcols = I80.isnull().all(axis=0)

# We'll drop them for convenience.
I80 = I80.loc[:, ~nullcols]

flowcols = [col for col in I80.columns if col.startswith("flow")]

I80["totalflow"] = I80[flowcols].sum(axis=1, skipna=True)

# 30 second aggregate level table
############################################################

# Some derived columns
# Takes a few minutes
I80["timestamp"] = pd.to_datetime(I80["timestamp"],
        infer_datetime_format=True)

I80["weekday"] = I80["timestamp"].dt.dayofweek
I80["hour"] = I80["timestamp"].dt.hour
I80["minute"] = I80["timestamp"].dt.minute

actual_second = I80["timestamp"].dt.second

# secs = actual_second.value_counts().sort_index()
# secs[:30].sum()
# secs[30:].sum()
# This shows that the natural way to separate is into these groups
# 0 - 29, 30 - 59

I80["second"] = (30 * np.floor(actual_second / 30)).astype("int")

# Verify same as above
# I80["second"].value_counts()

# For each lane and variable compute median values
I80median = (I80
            .iloc[:, 1:]  # exclude timestamp
            .groupby("ID weekday hour minute second".split())
            .median()
            )

I80median.to_csv(datadir + "I80_median.csv.gz",
        float_format="%.8g",
        compression="gzip",
        )

# Station level table
############################################################

idgroup = I80["totalflow"].groupby(I80["ID"])
station_summary = pd.DataFrame({
        "flow_max":     idgroup.max(),
        "flow_99":      idgroup.quantile(0.99),
        "flow_total":   idgroup.sum(),
        "flow_median":  idgroup.median(),
        "n_obs":        idgroup.count(),
        })

station_summary = station_summary.sort_index()

station_summary.to_csv(datadir + "station_summary.csv")

# Time series for a single station
############################################################

richards = I80[I80["ID"] == 318113]

cols = """timestamp flow1 occupancy1
flow2 occupancy2
flow3 occupancy3
totalflow weekday hour minute second
"""

richards = (richards[cols.split()]
        .set_index("timestamp")
        .sort_index()
        )

richards.to_csv(datadir + "richards.csv.gz",
        float_format="%.8g",
        compression="gzip",
        )
