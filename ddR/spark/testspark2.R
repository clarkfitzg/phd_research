# So I need to load some data into Spark.

library(sparklyr)
library(dplyr)

# Sets up a local instance of Spark
sc = spark_connect(master = "local")

# Loads the iris table into Spark
iris_tbl = copy_to(sc, iris, overwrite=TRUE)

# Why are these all NA?
iris_tbl %>% group_by(Species) %>% summarize(avglength =
mean("Sepal.Length")) %>% collect

# Try a user defined function - gives Undefined function error in SQL
# (Which is to be expected)
bake = function(x) data.frame(delicious = pi)
iris_tbl %>% group_by(Species) %>% summarize(delicious = bake("Sepal.Length"))

############################################################

# Now can we manipulate this at some lower level?
library(sparkapi)

# Class is "spark_jobj"
iris_low = spark_dataframe(iris_tbl)

# Following example function in sparkapi docs

# This is pretty darn far from passing in arbitrary R code
billionBigInteger <- invoke_new(sc, "java.math.BigInteger", "1000000000")
class(billionBigInteger)

# So it appears the ... in the invoke functions pass arguments into the
# Java objects. Which is the natural thing to do.
a = invoke_static(sc, "java.lang.Math", "hypot", 10, 20) 

# Doesn't work
invoke(iris_low, "select", "Sepal_Length")

# So this is the experimental Dataset class from Spark 1.6
# NOT an RDD. But probably pretty similar.
# http://spark.apache.org/docs/latest/api/java/index.html?org/apache/spark/sql/Dataset.html
invoke(iris_low, "getClass")

invoke(iris_low, "schema")

# From error log:
# 16/07/08 16:45:25 WARN RBackendHandler: select(class org.apache.spark.sql.TypedColumn,class org.apache.spark.sql.TypedColumn)
# 16/07/08 16:45:25 WARN RBackendHandler: select(class [Lorg.apache.spark.sql.Column;)
# 16/07/08 16:45:25 ERROR RBackendHandler: select on 198 failed

# Cross referencing with this:
# http://spark.apache.org/docs/latest/sql-programming-guide.html
invoke(iris_low, "printSchema")

# hc = hive_context(sc)

# Let's convert it to the more stable and familiar data frame
iris_df = invoke(iris_low, "toDF")

# Still a Dataset
invoke(iris_df, "getClass")

# This method of writing it should be equivalent.
invoke(iris_low, "toDF") %>% invoke("getClass")
