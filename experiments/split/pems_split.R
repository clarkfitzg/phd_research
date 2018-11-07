# Mon Nov  5 14:47:35 PST 2018
#
# Using R's iotools package to split the PEMS data into the required
# grouping variable, and also filter.

library(iotools)


# Return a vector of types with column names
pems_columns = function(nlanes = 8)
{
    lane_number = rep(seq.int(nlanes), each = 3)
    nm = rep(c("flow", "occupancy", "speed"), nlanes)
    nm = paste0(nm, lane_number)
    nm = c("timestamp", "station", nm)
    out = rep(c("integer", "numeric", "integer"), nlanes)
    out = c("POSIXct", "integer", out)
    names(out) = nm
    out
}


process_file = function(fname, keepers = c("station", "flow2", "occupancy2"))
{
    columns = pems_columns()
    keep_col = names(columns) %in% keepers
    columns[!keep_col] = "NULL"

    con = gzfile(fname, open = "rb")
    reader = chunk.reader(con)
    out = chunk.apply(reader, function(chunk){
        dstrsplit(chunk, col_types = columns, sep = ",")
        # Can't seem to get the row names out of here... Oh well.
        #write.csv.raw(y, yfile, append = TRUE, sep = ",", nsep = ",", col.names = FALSE)
    })
    close(con)
    colnames(out) = names(columns[keep_col] )
    out
}


if(FALSE)
{

    testfile = "~/data/pems/d04_text_station_raw_2016_04_13.txt.gz"

system.time(
    test <- process_file(testfile)
)

# Defaults:
#   user  system elapsed
#  6.184   0.596   6.858
#   user  system elapsed
#  5.892   0.448   6.406
#   user  system elapsed
#  6.064   0.540   6.607

system.time(write.table(test, "~/data/pems/threecolumns.csv"
                        , sep = ",", row.names = FALSE, col.names = FALSE))
#   user  system elapsed
# 13.624   0.072  13.696


split_column_name = "station"
split_column = names(test) == split_column_name

system.time(
    ts <- split(test[, !split_column], test[, split_column])
)
#   user  system elapsed
# 17.840  30.008  47.850
# Ouch, this is extremely slow :(

#rownames(test) = NULL

system.time(
    test2 <- test[order(test[, split_column_name]), ]
)
#   user  system elapsed
#  1.064   0.112   1.176

system.time(write.table(test2, "~/data/pems/threecolumns_sorted.csv"
                        , sep = ",", row.names = FALSE, col.names = FALSE))



    con = gzfile(testfile, open = "rt")

t1 = read.table(con, sep = ",", nrows = 10)

}
