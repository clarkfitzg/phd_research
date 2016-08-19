# Sun Jul 24 07:39:35 PDT 2016

library("SparkR")

n = 3
df = data.frame(key = 1:n)
df$value = lapply(letters[1:n], serialize, connection = NULL)

sparkR.stop()
sc <- sparkR.init()
sqlContext <- sparkRSQL.init(sc)

spark_df = createDataFrame(sqlContext, df)

# Fails
dapplyCollect(spark_df, function(x) x)

df2 = data.frame(a=1:n, b = letters[1:n])
spark_df2 = createDataFrame(sqlContext, df2)
# Works fine
dapplyCollect(spark_df2, function(x) x)
