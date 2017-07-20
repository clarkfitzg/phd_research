import pandas as pd
import pyarrow.parquet as pq


pems_dataset = pq.ParquetDataset('../hadoop/pems10rows_parquet/')

pems_table = dataset.read()

# The only surprise here is that 'station' is not an integer as in hive, it's a
# category mapping to station integers. Must have been a result from
# partitioning by 'station' when the parquet file was written.
pems_pandas = pems_table.to_pandas()


############################################################

pems2 = pq.ParquetFile("/Users/clark/data/pems/pems2.parquet")

station = pems2.read(["station"])

st = station.to_pandas()["station"]

counts = st.value_counts()

unique_stations = set(st.values)

len(unique_stations)

# 3115 stations appear here.
# I want to see all observations for each station together
# => This didn't work.
