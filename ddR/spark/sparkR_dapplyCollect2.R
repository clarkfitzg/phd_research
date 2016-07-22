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
if(TRUE){

sparkR.stop()

sc <- sparkR.init()
sqlContext <- sparkRSQL.init(sc)

spark_df = createDataFrame(sqlContext, df_rawvals)

# Works fine 
collect(spark_df)

# Fails with
#  Error in (function (..., deparse.level = 1, make.row.names = TRUE,
#  stringsAsFactors = default.stringsAsFactors())  :
#  invalid list argument: all variables should have the same length

spark_df1 = dapplyCollect(spark_df, wrapper1)

class(spark_df2$value[[1]])

# This then shows that SparkR is capable of directly reading and writing
# serialized R objects as raw vectors. Which is the main thing I needed.
}
