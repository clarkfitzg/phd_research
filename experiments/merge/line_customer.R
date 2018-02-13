# Tue Feb 13 09:22:56 PST 2018
#
# Make 3 large tables
#
# These will be used to benchmark / profile merge versus loading from disk.

DATADIR = "~/data/sales/"

n_item = 1e9
n_order = 100e6
n_customer = 10e6


write_rand_col = function(file, n, size, key = FALSE)
{
    data = if(key) seq(n), else sample.int(n, size, replace = True)
    saveRDS(data, paste0(DATADIR, file))
}
