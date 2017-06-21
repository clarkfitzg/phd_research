# I'd like to process a file in chunks. This requires reading the file
# until no more data is available.
#
# QUESTION: What is a better way of breaking out of this while loop?


# Generate some example data
fname = "some_big_table.txt"
write.table(iris, fname)

# Prepare the file read
infile = file(fname)
open(infile, "rt")
rows_per_chunk = 50L
chunk_number = 1L

moreinput = TRUE
moreinput_env = environment()

while(moreinput){

    tryCatch(chunk <- read.table(infile, nrows = rows_per_chunk),
        #error = function(e) assign("moreinput", FALSE, envir = moreinput_env)
        error = function(e) moreinput <<- FALSE
        )

    # Data processing code goes here
    cat(chunk_number, "\n")
    chunk_number = chunk_number + 1L
}

close(infile)
unlink(fname)
