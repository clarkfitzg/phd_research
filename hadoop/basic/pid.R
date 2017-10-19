#!/usr/bin/env Rscript
tryCatch({


sep = "\t"

infile = file("stdin")

tbl = read.table(infile, sep = sep)
pid = Sys.getpid()

tbl = cbind(tbl, pid, nrow(tbl))

stop("Ground Control to Major Tom")

write.table(tbl, stdout(), sep = sep
            , col.names = FALSE, row.names = FALSE)


}, error = function(e) cat(e))
