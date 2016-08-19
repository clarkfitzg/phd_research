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

############################################################

list_of_dfs <- rows

list_of_lists <- lapply(list_of_dfs, as.list)

do.call(rbind, list_of_lists)

# Fails
#df4 <- do.call(rbind.data.frame, list_of_lists)

# TODO: write a function that rbinds and deals with binary objects
rbind_withlists <- function(...)

lapply(list_of_lists, as.data.frame)

############################################################
#Fri Aug 19 14:37:28 KST 2016

# Here's what may well be going on in Spark's dapplyCollect:

keys = as.list(1:5)
values = lapply(keys, serialize, NULL)
list_of_lists <- mapply(list, keys, values, SIMPLIFY = FALSE, 
        USE.NAMES = FALSE)

# Then dapplyCollect is doing something like this, which fails because of
# the vectors which have a different length. So we need to make this work.
do.call(rbind.data.frame, list_of_lists)

# Sanity check that this works with appropriate rows
list_of_lists2 <- mapply(list, 1:5, letters[1:5], SIMPLIFY = FALSE,
        USE.NAMES = FALSE)
out2 = do.call(rbind.data.frame, list_of_lists2)
# Yes, no problem

# We're only worried about raws and vectors of length greater than 1 I
# think. So one way to do it is to identify raw vectors and handle them

row1 <- list_of_lists[[1]]

rawcolumns <- "raw" == sapply(row1, class)

if(any(rawcolumns))

row_to_df <- function(row, rawcolumns){
    # Converts row from a list to data.frame, respecting raw columns
    cleanrow <- row
    cleanrow[rawcolumns] <- NA
    dframe <- data.frame(cleanrow, stringsAsFactors = FALSE)
    dframe[rawcolumns] <- lapply(row[rawcolumns], list)
    rownames(dframe) <- NULL
    colnames(dframe) <- NULL
    dframe
}

row_to_df(row1)

rbind_df_with_raw <- function(list_of_rows, rawcolumns){

    cleanrows <- lapply(list_of_rows, row_to_df, rawcolumns)
    args <- c(cleanrows, list(make.row.names = FALSE))

    do.call(rbind.data.frame, cleanrows)

    do.call(rbind, cleanrows)

}

rbind_df_with_raw(list_of_lists, rawcolumns)

# This is heavily row based. And it's not working well!
# Can we do it in a more vectorized way?
# What if we just "fill in" a dataframe?


