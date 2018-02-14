# Tue Feb 13 16:14:12 PST 2018

library(data.table)
library(microbenchmark)

DATADIR = "~/data/sales/"


system2("vmtouch", c("-t", DATADIR))

system2("vmtouch", c("-v", DATADIR))

system.time(
item <- data.table(item = readRDS(paste0(DATADIR, "item/item"))
    , order = readRDS(paste0(DATADIR, "item/order"))
    )
)

# 9.3 seconds to load 1.6 GB object from disk
# Implies disk IO speed around 170 MB/second
io_speed = 1600 / 9.3
# Also 2-3 seconds to load from memory. Why does it take this long?
# Because that's how long it takes to copy a 1.6 GB object in memory, even
# from within an R process.

order <- data.table(order = readRDS(paste0(DATADIR, "order/order"))
    , customer = readRDS(paste0(DATADIR, "order/customer"))
    #, key = "order"
    )

o2 = order[sample(1000), ]

# ~10 seconds for 200 million records inner joined with 1000 records to make
# a table with ~ 10K records.
tmerge = system.time(item2 <- merge(item, o2, by = "order", sort = FALSE))

# But suppose we have an intermediate table of the indices in the big item
# table saying which ones we need to make the join.
# ~5.3 seconds
system.time({
    item_index = which(item$order %in% o2$order)
})

# Then the remaing steps take no time at all.
system.time({
    o2_index = match(item2$order, o2$order)
    item2 = cbind(item[item_index, ], o2[o2_index, ])
})

# For static analysis the data isn't changing, so we can maintain these
# types of index lookup tables.

# I'm surprised that this approach is about 2x as fast as data.table's
# merge. Although the latter is certainly more general and robust.

# How about using the data.table version?
# Takes 5.1 seconds, ie. much more efficent
system.time({
    item2 = item[o2, , on = "order"]
})
