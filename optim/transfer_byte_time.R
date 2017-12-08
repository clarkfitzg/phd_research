# How long does it take to transfer a single byte of memory between
# processes?
#
# About 2 - 2.5 ns on my Mac
# Which is about 400 MB / sec. This is in the same ballpark as the IO speed
# for some SSD's.
# Forking has an overhead of about 3 ms or so. Then if the data is larger than 
# 400 * 0.003, or about 1 MB then it may be more efficient to fork even if
# there are existing workers.

library(microbenchmark)
library(parallel)

# Takes about 0.5 seconds
nbytes = 1e8
ints = as.integer(nbytes / 4)

f = function(...) 1:ints

nprocs = 2L

ts = microbenchmark(result <- lapply(1:nprocs, f), times = 10)
ts = median(ts$time) / 1e9

tp = microbenchmark(result <- mclapply(1:nprocs, f), times = 10)
tp = median(tp$time) / 1e9

time_f_one = ts/nprocs

# Assuming:
# 2. All nprocs run at full speed simultaneously
# 3. mclapply overhead is relatively negligible
time_transfer_one = (tp - time_f_one) / nprocs

time_transfer_one_byte = time_transfer_one / nbytes
print(time_transfer_one_byte)

bytes_per_sec = nbytes / time_transfer_one
print(bytes_per_sec)
