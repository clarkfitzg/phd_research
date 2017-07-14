"""
Hive contains a table called "pems". The goal is to write this to disk
in parquet files partitioned by the "station" column.

EDIT: couldn't get that to work, now I'll see if I can sort it.


Running with all defaults below. I see all 32 CPU's on the host machine
loaded, which is good.
-----------------------------

time spark-submit pems_to_parquet.py

"""


from pyspark import SparkContext
from pyspark.sql import HiveContext

sc = SparkContext()
sqlContext = HiveContext(sc)

# snappy compression recommended for Arrow
# Interesting- snappy is slightly smaller than gz for the 10 rows.
sqlContext.setConf("spark.sql.parquet.compression.codec", "snappy")

# Testing
#pems = sqlContext.sql("SELECT * FROM pems LIMIT 10")

pems = sqlContext.sql("SELECT * FROM pems ORDER BY station")

# Don't see options about file chunk sizes, probably comes from some 
# environment variable
# Later versions:
# pems.write.parquet("pems_sorted", compression = "snappy")
pems.write.parquet("pems_sorted")


