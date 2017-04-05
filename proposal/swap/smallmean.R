# Wed Mar 29 14:45:18 PDT 2017

library(scales)
library(microbenchmark)

n = 1:200

times = lapply(n, function(n_i){
    # The original code garbage collected after every microbenchmark.
    # This version had the two clear lines and showed fixed overhead around
    # 4.2 microseconds:

     gc()
     times = microbenchmark(mean(rnorm(n_i)))

    # Then I garbage collected before every single call.
    #times = microbenchmark(gc(), mean(rnorm(n_i)), control = list(order = "inorder"))
    data.frame(n = n_i, time = times$time)
})

times = do.call(rbind, times)

# Filter out gc() calls based on histogram- this will be different for different
# systems.
times = times[times$time < 2e7, ]

# Units are microseconds
times$time = times$time / 1000

smalltime = by(times$time, times$n, quantile)
smalltime = as.data.frame(do.call(rbind, smalltime))
smalltime = cbind(as.integer(row.names(smalltime)), smalltime)
colnames(smalltime) = c("n", "min", "q25", "median", "q75", "max")

pdf(paste0("smalltime_", Sys.info()["nodename"], ".pdf"))

with(smalltime, plot(n, median
                   , main = "time to compute mean(rnorm(n))"
                   , ylab = expression(paste("time (", mu, "s)"))
                   ))

dev.off()

fit = lm(time ~ n, data = times)


with(times[times$time < 20, ], plot(n, time, col = alpha("black", 0.06)))

rtimes = times[sample.int(nrow(times), 1000), ]
with(rtimes, plot(n, time, col = alpha("black", 0.5)))

sum(times$time > 21)
# How many were over 21? 200. This is exactly the number of times that gc()
# was called within the lapply. So it seems that the first evalution of
# anything following gc() takes an additional ~15 microseconds.

# Throw out the obvious outliers. Maybe garbage collection inside?
fit2 = lm(time ~ n, data = times[times$time < 20, ])

summary(fit2)

confint(fit2)
#                  2.5 %     97.5 %
# (Intercept) 4.20876198 4.25000930
# n           0.06412455 0.06448087
#
# For this simple task there's a fixed overhead of ~4.2 microseconds and an
# additional 64 nanoseconds for each additional n.

# TODO: So when is overhead "small enough"? A lot of this parallel stuff is
# just understanding and controlling overhead.
