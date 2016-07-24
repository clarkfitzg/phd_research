# Sun Jul 24 06:47:02 PDT 2016

# Is it possible to store numeric array values as entries in Spark
# dataframe?

library("SparkR")

n = 3

df = data.frame(key = 1:n)
x = rnorm(5)
df$value = list(x, x + 2, 10 * x)

somefunc = function(df){
    out = data.frame(key = df$key)
    out$value = rnorm(nrow(out))
    out
}

somefunc(df[1, ])

somefunc(df)

############################################################

# Now for the Spark stuff

sparkR.stop()
sc <- sparkR.init()
sqlContext <- sparkRSQL.init(sc)
spark_df = createDataFrame(sqlContext, df)

# this works => it's possible to store the arrays within the Spark
# dataframe

# Fails
# dapplyCollect(spark_df, somefunc)
#
#Error in invokeJava(isStatic = FALSE, objId$id, methodName, ...) :
#  org.apache.spark.SparkException: Job aborted due to stage failure: Task 0
#in stage 1.0 failed 1 times, most recent failure: Lost task 0.0 in stage
#1.0 (TID 1, localhost): org.apache.spark.SparkException: R computation
#failed with
# Error in readBin(con, raw(), stringLen, endian = "big") :
#  invalid 'n' argument
#Calls: source ... withVisible -> eval -> eval -> <Anonymous> -> readBin
#Execution halted
#
# So the problem is in n = stringLen in the function call.

# What about just the identity function?
# Same error
dapplyCollect(spark_df, function(x) x)
