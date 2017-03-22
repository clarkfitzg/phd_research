# Run this on Poisson

library(traffic)

do_one = function(fname)
{
    d = read30sec(fname, nrows = -1)
    split_write(d, d$ID, "/scratch/...")
    message(fname, "completed")
}

all_files = list.files("/scratch/...")

lapply(all_files, do_one)
