library(microbenchmark)
library(parallel)

workers = 4
cls = makeCluster(workers)

n = 400 * 1:10
d = 5

clusterExport(cls, "d")

time_rt = function(n){
    n_j = n / workers
    clusterExport(cls, "n_j", environment())
    serial = microbenchmark(mean(rt(n, d)))
    p = microbenchmark(mean(unlist(clusterEvalQ(cls, mean(rt(n_j, d))))))
    data.frame(serial = quantile(serial$time, 0.25)
               , parallel = quantile(p$time, 0.25)
               )
}


time_rt(1000)

times = lapply(n, time_rt)

t2 = do.call(rbind, times)

pdf("ser_vs_par.pdf")
plot(n, t2[, 1])
points(n, t2[, 2], pch = 2)
dev.off()
