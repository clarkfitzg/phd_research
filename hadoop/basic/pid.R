#!/usr/bin/env Rscript

sep = "\t"

infile = file("stdin")

tbl = read.table(infile, sep = sep)
pid = Sys.getpid()

tbl = cbind(tbl, pid, nrow(tbl))

write.table(tbl, stdout(), sep = sep
            , col.names = FALSE, row.names = FALSE)
