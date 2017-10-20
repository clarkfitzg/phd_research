#!/usr/bin/env Rscript
tryCatch({

infile = file("stdin")

tbl = readLines(infile)

# I don't see this anywhere on the Hadoop worker nodes.
# Maybe I can log directly to hdfs?
# Or is there a more robust way to read from stderr?
logfile = "/home/clarkf/hiveR.log"
writeLines("hot damn it's a log!", logfile)

stop("R error dude!")


}, error = function(e) print(e))
