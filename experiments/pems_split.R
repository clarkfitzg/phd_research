# Mon Nov  5 14:47:35 PST 2018
#
# Using R's iotools package to split the PEMS data into the required
# grouping variable, and also filter.

# For testing
# fname = "~/data/pems/d04_text_station_raw_2016_04_13.txt.gz"

library(iotools)

read30sec = function(file, posix_timestamp = FALSE, lanes = 1:2
                     , numlanes = 8, nrows = 10000L, ...)
{
    ln = data.frame(number = rep(seq.int(numlanes), each = 3))
    ln$name = paste0(rep(c("flow", "occupancy", "speed"), numlanes), ln$number)
    ln$class = rep(c("integer", "numeric", "integer"), numlanes)
    ln$keep = ln$number %in% lanes
    ln$colname = ifelse(ln$keep, ln$name, "NULL")
    ln$colclass = ifelse(ln$keep, ln$class, "NULL")

    rawdata = read.table(file, header = FALSE, sep = ",", nrows = nrows
        , col.names = c("timestamp", "station", ln$colname)
        , colClasses = c("character", "integer", ln$colclass)
        , ...)


columns = c(
    ln$name = paste0(rep(c("flow", "occupancy", "speed"), numlanes), ln$number)
    ln$class = rep(c("integer", "numeric", "integer"), numlanes)
    ln$keep = ln$number %in% lanes
    ln$colname = ifelse(ln$keep, ln$name, "NULL")
    ln$colclass = ifelse(ln$keep, ln$class, "NULL")

pems_columns = function(nlanes = 8)
{

    lane_number = rep(seq.int(nlanes), each = 3)
    column_title = rep(c("flow", "occupancy", "speed"), each = 3)
}


process_file = function(fname, keepers = c("timestamp", "station")
{

    con = gzfile(fname, open = "rb")

    reader = chunk.reader(con)

    chunk = read.chunk(reader)

    chunk.apply(reader, function(Xraw){
        X = dstrsplit(Xraw, col_types = cols, sep = ",")
        y = predict(fit, X)
        # Can't seem to get the row names out of here... Oh well.
        write.csv.raw(y, yfile, append = TRUE, sep = ",", nsep = ",", col.names = FALSE)
    }, CH.MAX.SIZE = chunksize)

}



mstrsplit
