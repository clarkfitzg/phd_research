#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

col = as.integer(args[1])
#col = 3L

#sep = args[2]
sep = "\t"

infile = file("stdin")
tbl = read.table(infile, sep = sep)

gam = gamma(tbl[, col])
tbl = cbind(tbl, gam)

write.table(tbl, stdout(), sep = sep
            , col.names = FALSE, row.names = FALSE)
