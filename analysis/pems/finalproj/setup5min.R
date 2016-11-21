# Sets up directory structure to save processed 5min files

args = commandArgs(trailingOnly = TRUE)
datadir = args[1]

source("helpers.R")
station = readstation()

freeways = unique(station$FwyDir)


days = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday"
         , "Saturday", "Sunday")

dirbuilder = function(day, fwy)
{
    paste(datadir, "5min", day, fwy, sep = "/")
}

dirnames = outer(days, freeways, dirbuilder)

sapply(dirnames, dir.create, recursive = TRUE)
