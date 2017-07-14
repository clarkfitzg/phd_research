import pyarrow.parquet as pq


pems_dataset = pq.ParquetDataset('../hadoop/pems10rows_parquet/')

pems_table = dataset.read()

# The only surprise here is that 'station' is not an integer as in hive, it's a
# category mapping to station integers. Must have been a result from
# partitioning by 'station' when the parquet file was written.
pems_pandas = pems_table.to_pandas()
