#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)
sep = args[1]
col = as.integer(args[2])

infile = file("stdin")
tbl = read.table(infile, sep = sep)

gam = gamma(tbl[, col])
tbl = cbind(tbl, gam)

write.table(tbl, stdout(), sep = sep)
