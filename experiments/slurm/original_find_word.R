# Fri Dec 28 09:31:48 PST 2018
# 
# Basic example of using SLURM to process a large file.
#
# All it does is grep for a word in one column, and return the matches.
#
# This version of the script won't work on the full data because DATAFILE is too big to fit in memory.

COLUMN = "description"
WORD = "education"
DATAFILE = "~/data/transaction_normalized.csv"

d = read.csv(DATAFILE)
dc = d[, COLUMN]

output = grep(WORD, dc, ignore.case = TRUE, value = TRUE)

fname = paste0("~/data/", COLUMN, "-", WORD, ".txt")
write(output, fname)
