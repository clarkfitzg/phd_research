#!/usr/bin/env Rscript
tryCatch({

col = 1L
sep = "\t"

infile = file("stdin")
tbl = read.table(infile, sep = sep)

userid = tbl[, 1]

agg = aggregate(tbl, by = tbl[, 1:2], length)
agg = agg[, 1:3]

write.table(agg, stdout(), sep = sep
            , col.names = FALSE, row.names = FALSE)


}, error = function(e) cat(e))
