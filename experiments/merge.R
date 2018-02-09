
library(microbenchmark)

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
)

# 45 ms with 10 tables
# 188 ms with 11 tables
microbenchmark(
tbig <- Reduce(function(x, y) merge(x, y, by = "key", all = FALSE)
               , tables, tables[[length(tables)]], right = TRUE)
)
