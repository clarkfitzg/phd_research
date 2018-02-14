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
# Also 2.2 seconds to load from memory
io_speed = 1600 / 9.3

order <- data.frame(item = readRDS(paste0(DATADIR, "order/order"))
    , order = readRDS(paste0(DATADIR, "order/customer"))
    )

tmerge = system.time(item <- merge(item, order))

