# Tue Feb 13 09:22:56 PST 2018
#
# Make 3 large tables
#
# These will be used to benchmark / profile merge versus loading from disk.

DATADIR = "~/data/sales/"

GB_MEMORY = 8
MEM_TO_USE = 0.1
BYTES_PER_ELEMENT = 4

n_item = GB_MEMORY * 2^30 * MEM_TO_USE / BYTES_PER_ELEMENT
n_order = n_item / 10
n_customer = n_order / 10


write_rand_col = function(file, n, n_unique, key = FALSE, dd = DATADIR)
{
    data = if(key) seq(n) else sample.int(n_unique, n, replace = TRUE)
    saveRDS(data, paste0(dd, file), compress = FALSE)
}

set.seed(2347890)

write_rand_col("item/item", n_item, key = TRUE)
write_rand_col("item/order", n_item, n_order)

write_rand_col("order/order", n_order, key = TRUE)
write_rand_col("order/customer", n_order, n_customer)

write_rand_col("customer/customer", n_customer, key = TRUE)
saveRDS(sample(letters, size = n_customer, replace = TRUE)
        , paste0(DATADIR, "customer/letter"), compress = FALSE)

