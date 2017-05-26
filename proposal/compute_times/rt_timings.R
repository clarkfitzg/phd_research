library(microbenchmark)
library(parallel)

workers = 2
cls = makeCluster(workers)

n = seq(from = 2, by = 1000, length.out = 11)
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
t2 = do.call(rbind, times) / 1e6

pdf("ser_vs_par.pdf", height = 4)
plot(n, t2[, 1], ylim = c(0, max(t2)), xlab = "n", ylab = "time (ms)", type = "l"
     , main = "Time to evaluate mean(rt(n, d))")
lines(n, t2[, 2], lty = 2)
legend("topleft", legend = c("serial", "parallel, 2 workers"), lty = c(1, 2))
dev.off()
