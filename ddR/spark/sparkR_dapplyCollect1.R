# Can we directly serialize raw vectors with Spark?

# Fri Jul 22 15:18:33 PDT 2016
# Trying once again

library("SparkR")

local_df = data.frame(key = 1:3, value = letters[1:3])

wrapper = function(df){
    out = data.frame(key = df$key)
    # So both of these work:
    #out$value = lapply(df$value, function(x) serialize(1:5, NULL))
    out$value = lapply(df$value, function(x) serialize(x, NULL))
    out
}

wrapper(local_df)

############################################################

# Now for the Spark stuff

sparkR.stop()
sc <- sparkR.init()
sqlContext <- sparkRSQL.init(sc)
spark_df = createDataFrame(sqlContext, local_df)

# Works fine 
collect(spark_df)

# Works!! Sweet!
spark_df2 = dapplyCollect(spark_df, wrapper)

class(spark_df2$value[[1]])

# This then shows that SparkR is capable of directly reading and writing
# serialized R objects as raw vectors. Which is the main thing I needed.
}
