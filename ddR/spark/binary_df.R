# Mon Jul 18 08:08:09 PDT 2016

# Goal: Store arbitrary objects in DataFrames as bytes to make dapply more
# general
# 
# Inefficient- this uses CLOB rather than BLOB
# Comments throughout this question are helpful
# http://stackoverflow.com/questions/5950084/how-to-handle-binary-strings-in-r

library(SparkR)

# Note that setting this global option will NOT show up in Spark. So don't use it.
#options(stringsAsFactors = FALSE)

to_byte_string = function(x) {
    # Convert arbitrary R object into string of bytes
    # Better way would be to use a binary connection
    paste(as.character(serialize(x, connection = NULL)), collapse = " ")
}

from_byte_string = function(x) {
    xcharvec = strsplit(x, " ")[[1]]
    xhex = as.hexmode(xcharvec)
    xraw = as.raw(xhex)
    unserialize(xraw)
}

a = 1:10
ab = to_byte_string(a)

# Sanity check
from_byte_string(ab)

b = letters
bb = to_byte_string(b)

c = as.factor(LETTERS)
cb = to_byte_string(c)

# The data.frame is only being used as a key value store
local_df = data.frame(key = 1:3, value = c(ab, bb, cb)
                        , stringsAsFactors = FALSE)

sapply(local_df, class)

# A UDF we'd like to apply to each element
take5 = function(x) x[1:5]

# Side note - Spark doesn't seem to grab the default parameter value 
# if I write it like this:
# 
# wrapper = function(df, func = take5){
#
# I see an error message like:
#
# Error in serialize(x, connection = NULL) : object 'take5' not found

wrapper = function(df){
    # Necessary because we can't assume that every row corresponds to a
    # partition
    func_bytes = function(xbytes){
        # Deserialize, apply function, reserialize
        # This would be an excessive amount of serialization if doing in
        # pipelined manner
        x = from_byte_string(xbytes)

        # Actual function body is here:
        fx = x[1:5]

        to_byte_string(fx)
    }
    out = sapply(df$value, func_bytes)
    data.frame(key = df$key, value = out, stringsAsFactors = FALSE)
}

local_df2 = wrapper(local_df)

# Worry about the key later
local_results = lapply(local_df2$value, from_byte_string)

############################################################# 

# Now for the Spark stuff
sc <- sparkR.init()
sqlContext <- sparkRSQL.init(sc)

spark_df = createDataFrame(sqlContext, local_df)

spark_df2 = dapplyCollect(spark_df, wrapper)

spark_results = lapply(spark_df2$value, from_byte_string)

# This gives what I expected:
# > spark_results = lapply(spark_df2$value, from_byte_string)
# > spark_results
# [[1]]
# [1] 1 2 3 4 5
# 
# [[2]]
# [1] "a" "b" "c" "d" "e"
# 
# [[3]]
# [1] A B C D E
# Levels: A B C D E F G H I J K L M N O P Q R S T U V W X Y Z

############################################################# 

# What happens if I attempt to use this idea with 100 MB matrices as
# values?

n = round(sqrt(1e8 / 8))

m1 = matrix(rnorm(n^2), nrow=n)
m2 = matrix(rnorm(n^2), nrow=n)

# Sanity check:
format(object.size(m1), units="MB")

# In a local R session this takes nearly 1 minute
l_df = data.frame(key = 1:2
                  , value = c(to_byte_string(m1), to_byte_string(m2))
                  , stringsAsFactors = FALSE)


