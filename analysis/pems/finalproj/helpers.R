#' Read a 30 second raw PeMS file
#'
#' Takes a conservative approach to cleaning data by only performing the following steps:
#' Occupancy greater than 1 is converted to NA
#'
#' ID is the station id. Name chosen to match metadata files.
#'
#' @param file Name of file to read
#' @param lanes Vector of lanes to read. Others ignored.
#' @param numlanes Total expected number of lanes in file
#' @param nrows Number of rows to read.
#' @param ... Additional parameters for read.table
#' @return data.frame
read30sec = function(file, lanes = 1:2, numlanes = 8, nrows = -1, ...)
{
    ln = data.frame(number = rep(seq.int(numlanes), each = 3))
    ln$name = paste0(rep(c("flow", "occupancy", "speed"), numlanes), ln$number)
    ln$class = rep(c("integer", "numeric", "integer"), numlanes)
    ln$keep = ln$number %in% lanes
    ln$colname = ifelse(ln$keep, ln$name, "NULL")
    ln$colclass = ifelse(ln$keep, ln$class, "NULL")

    rawdata = read.table(file, header = FALSE, sep = ",", nrows = nrows
        , col.names = c("timestamp", "ID", ln$colname)
        , colClasses = c("character", "integer", ln$colclass)
        , ...)

    rawdata$timestamp = as.POSIXct(rawdata$timestamp, format = "%m/%d/%Y %H:%M:%S")

    occupancy = grep("occupancy", colnames(rawdata), value = TRUE)

    occupancy_too_big = rawdata[, occupancy] > 1
    rawdata[, occupancy][occupancy_too_big] = NA

    rawdata
}

#' Extract the minutes 
#'
#' @param ts POSIXct timestamp
extract_minutes = function(ts){
    hours = as.integer(format(ts, "%H"))
    minutes = as.integer(format(ts, "%M"))
    60L * hours + minutes
}

