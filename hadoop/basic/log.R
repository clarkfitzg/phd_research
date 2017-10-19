#!/usr/bin/env Rscript
tryCatch({


infile = file("stdin")

sep = "\t"
tbl = read.table(infile, sep = sep)

stop("Ground Control to Major Tom.")


}, error = function(e) cat(e, file = stdout()))
