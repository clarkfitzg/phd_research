# Can we directly serialize raw vectors with Spark?

# Fri Jul 22 14:51:48 PDT 2016
# Trying again. Not working well.

library("SparkR")

a = 1:10
ar = serialize(a, NULL)

b = letters
br = serialize(b, NULL)

c = rnorm(17)
cr = serialize(c, NULL)

local_df = data.frame(key = 1:3)
# Using a list-column
local_df$value = list(ar, br, cr)

sapply(local_df, class)

# A list of raw vectors
class(local_df$value[[1]])

wrapper = function(df){
    # Necessary because we can't assume that every row corresponds to a
    # partition

    func_raw = function(xraw){
        # Unserialize, apply function, reserialize
        x = unserialize(xraw)
        # Actual function body is here:
        fx = x[1:5]
        serialize(fx, NULL)
    }
    out = data.frame(key = df$key)
    out$value = lapply(df$value, func_raw)
    out

}

# Will this work on both single rows of dataframes?
# Yes
wrapper(local_df[1, ])

# Works
local_df2 = wrapper(local_df)

# Worry about the key later
local_results = lapply(local_df2$value, unserialize)
local_results

############################################################

# Now for the Spark stuff
if(TRUE){

sparkR.stop()

sc <- sparkR.init()
sqlContext <- sparkRSQL.init(sc)

spark_df = createDataFrame(sqlContext, local_df)

# Works fine - No, some
collect(spark_df)

spark_df2 = dapplyCollect(spark_df, wrapper)

}
