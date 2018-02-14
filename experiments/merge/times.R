# Tue Feb 13 16:14:12 PST 2018

library(microbenchmark)

DATADIR = "~/data/sales/"


system2("vmtouch", c("-t", DATADIR))

system2("vmtouch", c("-v", DATADIR))

system.time(
item <- data.frame(item = readRDS(paste0(DATADIR, "item/item"))
    , order = readRDS(paste0(DATADIR, "item/order"))
    )
)

# 9.3 seconds to load 1.6 GB object from disk
# Implies disk IO speed around 170 MB/second
io_speed = 1600 / 9.3
# Also 2-3 seconds to load from memory. Why does it take this long?
# Because that's how long it takes to copy a 1.6 GB object in memory, even
# from within an R process.

order <- data.frame(item = readRDS(paste0(DATADIR, "order/order"))
    , order = readRDS(paste0(DATADIR, "order/customer"))
    )

o2 = order[1:1000, ]

tmerge = system.time(item <- merge(item, o2))

