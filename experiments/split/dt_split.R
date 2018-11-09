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
    file_no_extension = gsub("\\..*", "", input$fname)
    newdir = paste0(topdir, "/", split_column_name, "/", file_no_extension)
    dir.create(newdir, recursive = TRUE)

    input$data[, fwrite(.SD, paste0(newdir, station), col.names = FALSE), by=station]
}


if(FALSE)
{

    testfile = "~/data/pems/d04_text_station_raw_2016_04_13.txt.gz"

system.time(
    t2 <- read_file(testfile)
)
# About the same as iotools
#   user  system elapsed
#  5.924   0.284   6.212

system.time(
    split_and_write(t2)
)

}
