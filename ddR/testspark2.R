# So I need to load some data into Spark.

library(sparklyr)
library(dplyr)

# Sets up a local instance of Spark
sc = spark_connect(master = "local")

# Loads the iris table into Spark
iris_tbl = copy_to(sc, iris, overwrite=TRUE)

# Now can we manipulate this at some lower level?
library(sparkapi)

iris_low = spark_dataframe(iris_tbl)

# Following example function in sparkapi docs

# So it appears the ... in the invoke functions pass arguments into the
# Java objects. Which is the natural thing to do.
invoke_static(sc, "java.lang.Math", "hypot", 10, 20) 

# Doesn't work
invoke(iris_low, "select", "Sepal_Length")

# From error log:
# 16/07/08 16:45:25 WARN RBackendHandler: select(class org.apache.spark.sql.TypedColumn,class org.apache.spark.sql.TypedColumn)
# 16/07/08 16:45:25 WARN RBackendHandler: select(class [Lorg.apache.spark.sql.Column;)
# 16/07/08 16:45:25 ERROR RBackendHandler: select on 198 failed

# Cross referencing with this:
# http://spark.apache.org/docs/latest/sql-programming-guide.html
invoke(iris_low, "printSchema")

# hc = hive_context(sc)
