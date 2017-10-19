#!/usr/bin/env Rscript

sep = "\t"

infile = file("stdin")

tbl = read.table(infile, sep = sep)

tbl = cbind(tbl, pid)

write.table(tbl, stdout(), sep = sep)
