#!/usr/bin/env Rscript

# Tue Oct 17 10:04:00 PDT 2017
#
# Not removing whitespace as in the Python version.

sep = "\t"

#infile = stdin()
infile = file("stdin")

tbl = read.table(infile, sep = sep)

pid = Sys.getpid()

tbl = cbind(tbl, pid)

write.table(tbl, stdout(), sep = sep)
