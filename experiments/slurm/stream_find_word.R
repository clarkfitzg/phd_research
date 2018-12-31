# Reimplement bash grep in R, demonstrating how to process a stream.

args = commandArgs(trailingOnly = TRUE)

WORD = args[1]
if(is.na(WORD)) stop("Pass the word to search for as the first argument.")

NLINES = args[2]
if(is.na(NLINES)) NLINES = 1000L


input = file("stdin")
open(input)

output = stdout()
#browser()

while(TRUE){
    x = readLines(input, n = NLINES)
    if(length(x) == 0)
        break
    result = grep(WORD, x, ignore.case = TRUE, value = TRUE)
    writeLines(result, con = output)
}

close(input)
