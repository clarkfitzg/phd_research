#!/usr/bin/env Rscript
writeLines("BEGIN R SCRIPT", stderr())

infile = file("stdin")
tbl = read.table(infile, row.names = NULL)

msg = paste(c("tbl dimensions:", dim(tbl)), collapse = " ")
writeLines(msg, stderr())

agg = aggregate(tbl, by = tbl[, 1:2], length)
agg = agg[, 1:3]

write.table(agg, stdout(), sep = "\t"
            , col.names = FALSE, row.names = FALSE)
