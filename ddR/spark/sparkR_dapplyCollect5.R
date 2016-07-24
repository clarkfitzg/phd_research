# Can we operate on serialized R objects using a Spark Dataframe?

# Fri Jul 22 17:42:06 PDT 2016

# Is it possible to get anything at all from a spark dataframe with a
# binary column?

library("SparkR")

n = 3

df = data.frame(key = 1:n, value = letters[1:n])

df_rawvals = data.frame(key = 1:n)
df_rawvals$value = lapply(letters[1:n], serialize, connection = NULL)

somefunc = function(df){
    out = data.frame(key = df$key)
    out$value = rnorm(nrow(out))
    out
}

somefunc(df_rawvals[1, ])

somefunc(df_rawvals)

############################################################

# Now for the Spark stuff

sparkR.stop()
sc <- sparkR.init()
sqlContext <- sparkRSQL.init(sc)
spark_df = createDataFrame(sqlContext, df)
spark_df_rawvals = createDataFrame(sqlContext, df_rawvals)

#sch = structType(structField("key", "integer")
                #, structField("value", "double"))

# Some other error.
#collect(dapply(spark_df, somefunc, schema(spark_df)))

# Runs!
dapplyCollect(spark_df, somefunc)

# Fails
# dapplyCollect(spark_df_rawvals, somefunc)


# This means that it's something about operating on the list of raw values
# that's throwing the error.

# How about the identity function:
# Works as expected:
dapplyCollect(spark_df, function(x) x)

# Fails
# dapplyCollect(spark_df_rawvals, function(x) x)
