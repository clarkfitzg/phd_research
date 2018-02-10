
library(microbenchmark)

library(future)

fold = future:::fold

make_table = function(n = 1e5)
{
    data.frame(key = sample(n)
               , value = sample(n))
}

sizes = as.integer(exp(seq(11)))

set.seed(3180)
tables = lapply(sizes, make_table)

t1 = merge(tables[1], tables[4], by = "key", all = FALSE)
t2 = merge(t1, tables[5], by = "key", all = FALSE)
t3 = merge(t2, tables[5], by = "key", all = FALSE)


# 7 ms with 10 tables
# 18 ms with 11 tables
microbenchmark(
tbig <- Reduce(function(x, y) merge(x, y, by = "key", all = FALSE)
               , tables, tables[[1]], right = FALSE)
, times = 10L)

# This is basically equivalent to Reduce if the threshold < length(tables)
microbenchmark(
tbig_fold <- fold(tables
    , function(x, y) merge(x, y, by = "key", all = FALSE)
, left = TRUE, unname = FALSE, threshold = 6L), times = 10L)


# 45 ms with 10 tables
# 188 ms with 11 tables
# 1 order of magnitude
microbenchmark(
tbig <- Reduce(function(x, y) merge(x, y, by = "key", all = FALSE)
               , tables, tables[[length(tables)]], right = TRUE)
, times = 10L)

# The above times are pretty slow compared to the theoretical limitations.
# The first table has 2 keys, so if we go from the left as we should then
# we are never scanning for more than 2 keys. Further, we only need to scan
# about 100K rows in this example, which should be very fast.

total_rows = sum(sapply(tables, nrow))

# Not sure this is equivalent.
microbenchmark(
    lapply(tables, function(tbl) match(tbl$key, c(2, 6)))
, times = 10L)

# Make sure I understand what match and merge do
t1 = data.frame(key = c(1, 2, 3), v1 = c(4, 5, 6))
t2 = data.frame(key = c(1, 1), v2 = c(7, 8))

merge(t1, t2, by = "key", all = FALSE)
