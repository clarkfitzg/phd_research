# Can we directly serialize raw vectors with Spark?

# Fri Jul 22 15:18:33 PDT 2016
# Trying once again

library("SparkR")

n = 3
df_rawvals = data.frame(key = 1:n)
df_rawvals$value = lapply(letters[1:n], serialize, connection = NULL)

wrapper1 = function(df){
    out = data.frame(key = df$key)
    out$value = lapply(df$value, function(x){
        serialize(1:5, NULL)
    })
    out
}

wrapper2 = function(df){
    out = data.frame(key = df$key)
    out$value = lapply(df$value, function(x){
        toupper(unserialize(x))
    })
    out
}

wrapper1(df_rawvals)

wrapper2(df_rawvals)

############################################################

# Now for the Spark stuff

sparkR.stop()
sc <- sparkR.init()
sqlContext <- sparkRSQL.init(sc)
spark_df = createDataFrame(sqlContext, df_rawvals)

#spark_df2 = dapplyCollect(spark_df, wrapper2)
# Fails with
#  Error in (function (..., deparse.level = 1, make.row.names = TRUE,
#  stringsAsFactors = default.stringsAsFactors())  :
#  invalid list argument: all variables should have the same length

# => unserialization did not work
