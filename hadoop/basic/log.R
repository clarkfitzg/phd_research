#!/usr/bin/env Rscript
tryCatch({


infile = file("stdin")

tbl = readLines(infile)

stop("R error dude!")


}, error = function(e) print(e))
