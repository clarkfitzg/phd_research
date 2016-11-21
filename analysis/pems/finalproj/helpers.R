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


#' Helper for infer_colnames
columns_from_html = function(htmlfile){

    tree = XML::htmlParse(htmlfile)
    rows = XML::getNodeSet(tree, '//div[@id="Help_station_5min"]//tr')

    # These positions may be different
    readrow = function(row) XML::getChildrenStrings(row)[c(1, 3)]
    # Some newlines seem to be missing, but oh well.

    cleanrows = lapply(rows, readrow)
    out = data.frame(do.call(rbind, cleanrows[-1]))
    colnames(out) = cleanrows[[1]]
    out
}


#' Read Pems column names and metadata from a saved html file
#'
#' @param htmlfile Name of save 
infer_colnames = function(htmlfile = "5min.html", nlanes = 8)
{
    columns = columns_from_html(htmlfile)
    original = as.character(columns[["Name"]])
    original = gsub("%", "Percent", original)

    pattern = "Lane N"
    haslanes = grep(pattern, original)
    lanes = columns[["Name"]][haslanes]

    replaceN = function(N) gsub(pattern, paste("Lane", N), lanes)
    withN = lapply(seq(nlanes), replaceN)

    withN = c(list(original[- haslanes]), withN)
    out = unlist(withN)
    gsub(" ", "", out)
}


cache = function()
{
    header = infer_colnames()
    write.table(header, "header5min.txt", row.names = FALSE, col.names = FALSE)

    # Ugly munging, but what can you do?
    tree = XML::htmlParse("chp_month.html")
    rows = XML::getNodeSet(tree, "//tr")
    readrow = function(row) XML::getChildrenStrings(row)[3]
    cleanrows = lapply(rows, readrow)
    chp = unname(unlist(cleanrows[3:22]))
    chp = gsub(" ", "", chp)
    chp[grepl("Duration", chp)] = "Duration"

    write.table(chp, "headerCHP.txt", row.names = FALSE, col.names = FALSE)

}


readstation = function(file = "~/data/pems/d04_text_meta_2016_10_05.txt")
{
    station = read.table(file
                         , sep = "\t"
                         , header = TRUE
                         , quote = ""
                         , stringsAsFactors = FALSE
                         )[, c("ID", "Abs_PM", "Fwy", "Dir", "Type")]

    station[, "FwyDir"] = paste0(station[, "Fwy"], station[, "Dir"])

    # Only considering Mainline stations
    station = station[station[, "Type"] == "ML", ]

    station[, "Type"] = NULL
    station[, "Fwy"] = NULL
    station[, "Dir"] = NULL
    station
}
