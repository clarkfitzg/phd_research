NLINES = 1000L

WORD = "education"

input = file("stdin")
open(input)

output = stdout()

while(isIncomplete(input)){
    x = readLines(input, n = NLINES)
    result = grep(WORD, x, ignore.case = TRUE, value = TRUE)
    writeLines(result, con = output)
}

close(input)
