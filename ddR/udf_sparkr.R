library("SparkR")

# Testing out UDF's in SparkR

sc = sparkR.init("local")

sqlContext = sparkRSQL.init(sc)

iris_df = createDataFrame(sqlContext, iris)

bake = function(x) data.frame(funstuff = pi * 1:4)

i2 = collect(iris_df)

# Expecting 150 ones in a dataframe - just gives one though
ones = dapplyCollect(iris_df, bake)

i3 = repartition(iris_df, col = iris_df$"Species")

# Expecting 3 ones - great, it did it.
# Actually kicks off the Spark job too. Encouraging.
ones2 = dapplyCollect(i3, bake)


