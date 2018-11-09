# Mon Nov  5 14:47:35 PST 2018
#
# Using R's iotools package to split the PEMS data into the required
# grouping variable, and also filter.

library(iotools)

library(data.table)

# Only one thread
setDTthreads(1L)


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


read_file_iotools = function(fname, keepers = c("station", "flow2", "occupancy2"))
{
    columns = pems_columns()
    keep_col = names(columns) %in% keepers
    columns[!keep_col] = "NULL"

    con = gzfile(fname, open = "rb")
    reader = chunk.reader(con)
    out = chunk.apply(reader, function(chunk){
        dstrsplit(chunk, col_types = columns, sep = ",")
    })
    close(con)
    colnames(out) = names(columns[keep_col] )
    row.names(out) = NULL
    out
}


# Interesting Note from Matt Dowle in data.table NEWS:
#
# 1. `fread()` can now read `.gz` and `.bz2` files directly; e.g.
# `fread("file.csv.gz")`. It uses `R.utils::decompressFile` to decompress
# to a `tempfile()` which is then read by `fread()` in the usual way. For
# greater speed on large RAM servers, it is recommended to set `TEMPDIR` to
# `/dev/shm` to use ramdisk for temporary file; see `?tempdir`. Reading a
# remote compressed file in one step will be supported in the next version;
# i.e. `fread("http://domain.org/file.csv.bz2")`.
#
# Also tmpfs https://en.wikipedia.org/wiki/Tmpfs

read_file_datatable = function(fname, keepers = c("station", "flow2", "occupancy2"))
{

    select = match(keepers, names(pems_columns()))

    #con = gzfile(fname, open = "rb")
    cmd = paste0("zcat ", fname)
    out = data.table::fread(cmd, sep = ",", select = select)
    colnames(out) = keepers
    out
}



if(FALSE)
{

    testfile = "~/data/pems/d04_text_station_raw_2016_04_13.txt.gz"

system.time(
    test <- read_file_iotools(testfile)
)
# Defaults:
#   user  system elapsed
#  6.184   0.596   6.858
#   user  system elapsed
#  5.892   0.448   6.406
#   user  system elapsed
#  6.064   0.540   6.607

system.time(
    t2 <- read_file_datatable(testfile)
)
# About the same as iotools
#   user  system elapsed
#  5.924   0.284   6.212




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
#   user  system elapsed
# 16.708  11.924  28.639
# Ouch, this is extremely slow :(

system.time(
    h <- by(test, test[, split_column], head)
)
# This is slow too.

library(data.table)

tdt = as.data.table(test)
setkeyv(tdt, split_column_name)

system.time(
    sp <- tdt[, .SD[1:6], by=station]
)
# Much faster
#   user  system elapsed
#  0.612   0.012   0.623



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
