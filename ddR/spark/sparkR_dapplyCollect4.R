# Can we directly serialize raw vectors with Spark?

# Fri Jul 22 16:41:16 PDT 2016

# Can we unserialize, apply func, then reserialize?

library("SparkR")

local_df = data.frame(key = 1:3, value = letters[1:3])

serialize_spark = function(df){
    out = data.frame(key = df$key)
    out$value = lapply(df$value, serialize, connection = NULL)
    out
}


serialize_spark_anonymous = function(df){
    out = data.frame(key = df$key)
    out$value = lapply(df$value, function(x) serialize(x, NULL))
    out
}

unserialize_spark = function(df){
    out = data.frame(key = df$key)
    out$value = lapply(df$value, unserialize)
    out
}

unserialize_spark_anonymous = function(df){
    out = data.frame(key = df$key)
    out$value = lapply(df$value, function(x) unserialize(x))
    out
}


############################################################

# Now for the Spark stuff

sparkR.stop()
sc <- sparkR.init()
sqlContext <- sparkRSQL.init(sc)
spark_df = createDataFrame(sqlContext, local_df)

# Works - Creates the serialized version of the values
local_ser = dapplyCollect(spark_df, serialize_spark)
spark_ser = createDataFrame(sqlContext, local_ser)

# Works
unserialize_spark(collect(spark_ser))

# local_df2 = dapplyCollect(spark_ser, unserialize_spark)
# Fails with same error
# Calls: source ... withVisible -> eval -> eval -> do.call -> <Anonymous>
# Execution halted
# Error in (function (..., deparse.level = 1, make.row.names = TRUE,
# stringsAsFactors = default.stringsAsFactors())  :
#   invalid list argument: all variables should have the same length

# local_df2 = dapplyCollect(spark_ser, unserialize_spark_anonymous)
# Fails with same error

# Conclusion: Serialization works, while unserialization doesn't.
# Maybe I only thought that it worked before.
