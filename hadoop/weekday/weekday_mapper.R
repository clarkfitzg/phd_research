#!/usr/bin/env Rscript
stdin <- file("stdin")
open(stdin)
stdout <- stdout()

finished <- FALSE

tryCatch(
    line <- read.table(stdin, sep = "\t", nrows = 1)
    , error = function(e) finished <<- TRUE
)

while(!finished) {
    line[, 4] = NULL
    line[, 4] = sample(7, size = 1)
    write.table(line, file = stdout, sep = "\t"
            , col.names = FALSE, row.names = FALSE)

tryCatch(
    line <- read.table(stdin, sep = "\t", nrows = 1)
    , error = function(e) finished <<- TRUE
)
}
