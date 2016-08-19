# Fri Aug 19 10:57:07 KST 2016
#
# For the Spark patch to work I need to figure out how to split and
# recombine a dataframe with a column of raw bytes

df <- data.frame(key = 1:5)
df$value <- lapply(df$key, serialize, NULL)

# list of dataframes
rows <- split(df, seq_len(nrow(df)))

df2 <- do.call(rbind, rows)

# Does what I wanted to happen
class(df2$value[[1]])

# looks like this does exactly the same thing.
df3 <- do.call(rbind.data.frame, rows)


# So then what is SparkR doing differently??
