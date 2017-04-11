source("predictY_iotools.R")

n = as.integer(c(100, 200, 500, 1000, 3000, 10000, 100000))
#n = 10000L

# Do the faster ones first :)
n = rev(n)

# This parallel version is using a new process every time. I wonder if
# they're fighting over file resources? Probably will need to try this with
# various values
nprocs = 4L

# Write as we go in case of crashing
lapply(n, function(n_i){
    time = system.time({predictY(n_i, yfile = "/ssd/clarkf/Y2.csv")})
    output = data.frame(n = n_i, time = time["elapsed"])
    write.table(output, "timings_iotools.csv", append = TRUE, row.names = FALSE, col.names = FALSE)
    message("Finished ", n_i)
})

# Not working:
#
# clarkf@fingers ~/phd_research/proposal/predict (master)
# $ Rscript time_predictY_iotools.R 
# Finished 100000
# Finished 10000
# Finished 3000
# 
#  *** caught segfault ***
# address 0x150, cause 'memory not mapped'
# 
# Traceback:
#  1: length(x)
#  2: dstrsplit(Xraw, col_types = cols, sep = ",")
#  3: (function (Xraw) {    X = dstrsplit(Xraw, col_types = cols, sep = ",")    y = predict(fit, X)    write.csv.raw(
# y, yfile, append = TRUE, sep = ",", nsep = ",",         col.names = FALSE)})(NULL)
#  4: .Call(chunk_apply, reader, CH.MAX.SIZE, CH.MERGE, FUN, parent.frame(),     .External(pass, ...))
#  5: chunk.apply(reader, function(Xraw) {    X = dstrsplit(Xraw, col_types = cols, sep = ",")    y = predict(fit, X)
#     write.csv.raw(y, yfile, append = TRUE, sep = ",", nsep = ",",         col.names = FALSE)}, CH.MAX.SIZE = chunks
# ize)
#  6: predictY(n_i, yfile = "/ssd/clarkf/Y2.csv")
#  7: system.time({    predictY(n_i, yfile = "/ssd/clarkf/Y2.csv")})
#  8: FUN(X[[i]], ...)
#  9: lapply(n, function(n_i) {    time = system.time({        predictY(n_i, yfile = "/ssd/clarkf/Y2.csv")    })    o
# utput = data.frame(n = n_i, time = time["elapsed"])    write.table(output, "timings_iotools.csv", append = TRUE,   
#       row.names = FALSE, col.names = FALSE)    message("Finished ", n_i)})
# aborting ...
# Segmentation fault

