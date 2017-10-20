#!/usr/bin/env Rscript
writeLines("\n\n\n\n\nBEGIN R LOG\n", stderr())

infile = file("stdin")

stop("R error dude!")

tbl = readLines(infile, n = 100L)

# I don't see this anywhere on the Hadoop worker nodes.
# Maybe I can log directly to hdfs?
# Or is there a more robust way to check the stderr?
#logfile = "/home/clarkf/hiveR.log"
#writeLines("hot damn it's a log!", logfile)


writeLines("\nEND R LOG", stderr())
