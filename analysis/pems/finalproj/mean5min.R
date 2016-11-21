

#' Read AvgOccupancy from 5 minute PeMS
#'
#' @param file Name of file to read
read5min = function(file, ...)
{

}



columns = read.table("header5min.txt", stringsAsFactors = FALSE)[, 1]
keep = columns %in% c("Timestamp", "Station", "AvgOccupancy")
columns[!keep] = "NULL"
colclass = columns
colclass[keep] = c("character", "integer", "numeric")

d = read.table("~/data/pems/d04_text_station_5min_2016_05_10.txt.gz"
               , sep = ","
               , stringsAsFactors = FALSE
               , col.names = columns
               , colClasses = colclass
               )

# Timestamps use a fixed number of characters.
# So we can extract based on index.
d[, "Hour"] = as.integer(substr(d[, "Timestamp"], 12, 13))
d[, "Minute"] = as.integer(substr(d[, "Timestamp"], 15, 16))


station = read.table("~/data/pems/d04_text_meta_2016_10_05.txt"
                     , sep = "\t"
                     , header = TRUE
                     , quote = ""
                     , stringsAsFactors = FALSE
                     )[, c("ID", "Abs_PM", "Fwy", "Dir", "Type")]

d2 = merge(d, station, by.x = "Station", by.y = "ID")


