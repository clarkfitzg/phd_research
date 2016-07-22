library("SparkR")

# Can we directly serialize raw vectors with Spark?


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

first5 = function(x) x[1:5]

rowfunc = function(func){
    # Higher order function to create functions that operate on rows of
    # (key, value) where value is a serialized (raw) R object
    # 
    function(row){
        x = unserialize(unlist(row$value))
        # fx = func(x, ...)
        # gives this error in Spark:
        #
        # Error in get(nodeChar, envir = func.env, inherits = FALSE) :
        # argument "..." is missing, with no default
        #
        fx = func(x)
        out = data.frame(key = row$key)
        out$value = list(serialize(fx, NULL))
        out
    }
}

row_first5 = rowfunc(first5)

row_first5(local_df[1, ])

local2 = apply(local_df, 1, row_first5)
local_df2 = do.call(rbind, local2)

# Worry about the key later
local_results = lapply(local_df2$value, unserialize)
local_results

############################################################

# Now for the Spark stuff
sc <- sparkR.init()
sqlContext <- sparkRSQL.init(sc)

spark_df = createDataFrame(sqlContext, local_df)

# Necessary to have as many partitions as rows
spark_df1 = repartition(spark_df, numPartitions = nrow(spark_df))

# Works fine
collect(spark_df1)

# Fails
fromspark = function(row){
    x = unserialize(unlist(row$value))
    fx = x[1:5]
    out = data.frame(key = row$key)
    out$value = list(serialize(fx, NULL))
    out
}

# Fails
dapplyCollect(spark_df1, fromspark)

# Fails
#spark_df2 = dapplyCollect(spark_df1, row_first5)
#
# org.apache.spark.SparkException: R computation failed with
# Error in (function (..., deparse.level = 1, make.row.names = TRUE,
# stringsAsFactors = default.stringsAsFactors())  :
#  invalid list argument: all variables should have the same length
# Calls: source ... withVisible -> eval -> eval -> do.call -> <Anonymous>

# This may be a problem with looking through the environments of the higher
# order function.
# So lets simplify a little

wrapper = function(row){
    x = unserialize(unlist(row$value))
    fx = x[1:5]
    out = data.frame(key = row$key)
    out$value = list(serialize(fx, NULL))
    out
}

# Same error
spark_df2 = dapplyCollect(spark_df1, wrapper)


# Ok, try the way it was before

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
    out$value = sapply(df$value, func_raw)
    out

}

# Works
wrapper(local_df)

# Fails with Broken pipe?
spark_df2 = dapplyCollect(spark_df1, wrapper)
