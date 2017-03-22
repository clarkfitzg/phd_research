# Run this on Poisson

library("traffic", lib.loc = "~/dev/traffic")

do_one = function(fname)
{
    d = read30sec(fname, nrows = -1)
    split_write(d, d$ID, "/scratch/clarkf/pems/stationID")
    message(fname, "completed")
}

all_files = list.files("/scratch/clarkf/pems/district4", full.names = TRUE)

lapply(all_files, do_one)
