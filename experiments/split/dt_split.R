# $ time R CMD BATCH dt_split.R                                                                     
# 
# real    96m11.425s
# user    81m25.427s
# sys     12m52.013s
#
# I watched iostat while this ran, and the read and write speeds never went beyond
# ~20 MB/sec, which is much lower than the physical limit which should be
# greater than 100 MB/sec.

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


read_file = function(fname, keepers = c("station", "flow2", "occupancy2"))
{
    select = match(keepers, names(pems_columns()))

    #con = gzfile(fname, open = "rb")
    cmd = paste0("zcat ", fname)
    out = data.table::fread(cmd, sep = ",", select = select)
    colnames(out) = keepers
    list(fname = fname, data = out)
}


split_and_write = function(input, split_column_name = "station")
{
    topdir = dirname(input$fname)
    file_no_extension = gsub("\\..*", "", basename(input$fname))

    # If we put the splitting column column name earlier in the directory
    # structure then it shows more quickly what we're splitting by.
    newdir = paste0(topdir, "/", split_column_name, "/", file_no_extension)
    dir.create(newdir, recursive = TRUE)

    input$data[, fwrite(.SD, paste0(newdir, "/", station), col.names = FALSE), by=station]
}


if(TRUE)
{

    files = c(list.files(path = "/scratch/clarkf/pems/district3", full.names = TRUE),
              list.files(path = "/scratch/clarkf/pems/district4", full.names = TRUE))

    lapply(files, function(fname){
        tmp = read_file(fname) 
        split_and_write(tmp)
    })

}


if(FALSE)
{
    # On my local machine

    testfile = "~/data/pems/d04_text_station_raw_2016_04_13.txt.gz"

    testfile = "/scratch/clarkf/pems/district4/d04_text_station_raw_2016_01_01.txt.gz"

system.time(
    t2 <- read_file(testfile)
)
# About the same as iotools
#   user  system elapsed
#  5.924   0.284   6.212

system.time(
    split_and_write(t2)
)
#   user  system elapsed
#  2.532   0.104   2.634
#    user  system elapsed
#   1.356   0.188   1.552

# Takes under 10 seconds.
# So we should be able to process 300 files like this in less than 
# 3000 / 60 = 50 minutes
# I can try different levels of parallelism to see when we hit the
# bottleneck with disk IO.
}
