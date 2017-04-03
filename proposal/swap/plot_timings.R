timings = read.table("timings.csv"
                     , col.names = c("n", "frac_memory", "seconds"))

png("spinning_disk_swap.png")
with(timings, plot(frac_memory, seconds
                   , xlab = "fraction of RAM"
                   , main = "Time to compute mean(rnorm(n)) for large n"
                   ))
abline(v = 0.95, lty = 2)
text(0.95, 400, "disk swap\nbegins", pos = 2)
dev.off()

timings_ssd = read.table("timings_ssd.csv"
                     , col.names = c("n", "frac_memory", "seconds"))

png("ssd_swap.png")
with(timings_ssd, plot(frac_memory, seconds
                   , xlab = "fraction of RAM"
                   , main = "Time to compute mean(rnorm(n)) for large n"
                   ))
abline(v = 1.02, lty = 2)
text(1, 1000, "disk swap\nbegins", pos = 2)
dev.off()


# *Comfortably* in memory
inmemory = timings[timings$frac_memory < 0.85, ]

fit = lm(seconds ~ frac_memory, data = inmemory)
# R^2 is 0.999, so this is essentially perfect

with(inmemory, plot(frac_memory, seconds, xlab = "fraction of RAM"))
