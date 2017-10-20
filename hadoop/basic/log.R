#!/usr/bin/env Rscript
tryCatch({

infile = file("stdin")

writeLines("hot damn it's a log!", stderr())



tbl = readLines(infile, n = 100L)

# I don't see this anywhere on the Hadoop worker nodes.
# Maybe I can log directly to hdfs?
# Or is there a more robust way to check the stderr?
#logfile = "/home/clarkf/hiveR.log"
#writeLines("hot damn it's a log!", logfile)

}, error = function(e) print(e))


stop("R error dude!")
