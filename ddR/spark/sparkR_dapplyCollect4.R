# Can we directly serialize raw vectors with Spark?

# Fri Jul 22 16:41:16 PDT 2016

# Can we unserialize, apply func, then reserialize?

library("SparkR")

local_df = data.frame(key = 1:3)
local_values = list(letters, 1:20, rnorm(7))
local_df$value = lapply(local_values, serialize, conn=NULL)

sapply(local_df, class)

# A list of raw vectors
class(local_df$value[[1]])

func_raw = function(xraw){
    # A function operating on serialized objects
    # Unserialize, apply function, reserialize
    x = unserialize(xraw)
    # Actual function body is here:
    fx = x[1:5]
    serialize(fx, NULL)
}

# Test this recovers the right thing
actual = unserialize(func_raw(local_df$value[[1]]))
stopifnot(all(actual == letters[1:5]))

wrapper = function(df){
    # Necessary because we can't assume that every row corresponds to a
    # partition
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

sparkR.stop()
sc <- sparkR.init()
sqlContext <- sparkRSQL.init(sc)
spark_df = createDataFrame(sqlContext, local_df)

# local_wrapper_applied = dapplyCollect(spark_df, wrapper)
# Yep, exact same failure.
# Let's grep through the Spark source and see if it's in there.
# Don't see it. Googling this gives me hits to the source of data.frame,
# cbind and rbind
