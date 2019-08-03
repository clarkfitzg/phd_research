# Column selection, picking out 3 of 26 columns
#
# time (seconds)    | tech
# ---------------------------------
# 10                | only iotools
# 15                | iotools + command line cut
# 5                 | only data.table

library(iotools)

DATAFILE = "~/data/pems/d04_text_station_raw_2016_08_22.txt.gz"

con = pipe(paste("gunzip --stdout", DATAFILE))

# Why does this take 5.7 seconds?
# The following scans the entire data and takes only 1.3 seconds.
#
# $ gunzip --stdout $DATAFILE | wc -l
#
system.time(
    r <- readAsRaw(con)
)

# 4 seconds
system.time(
    d <- dstrsplit(r, col_types = c("NULL", "integer", "integer", "numeric", rep("NULL", 22)), sep = ",")
)

head(d)

dim(d)

# About 10 seconds to load one file, and there are 300 files
# => about 50 minutes to load everything.
load_minutes = 10 * 300 / 60
# And then we still have to save and all that.


# 2
############################################################
# What if we do it in the shell?

con2 = pipe(paste("gunzip --stdout", DATAFILE, "| cut -d, -f 2-4"))

# 13.4 seconds
system.time(
    r2 <- readAsRaw(con2)
)

# 1.8 seconds
system.time(
    d <- dstrsplit(r2, col_types = c("integer", "integer", "numeric"), sep = ",")
)

# For a total of about 15 seconds, slower than iotools.

# 3
############################################################
# How about pure data.table

library(data.table)

# No threading
setDTthreads(1L)

# 4.9 seconds
system.time(
    d <- fread(cmd = paste("gunzip --stdout", DATAFILE), sep = ",", select = 2:4)
)
