# Rough timings, based on various experiments. Units are seconds

library(microbenchmark)
library(parallel)

twox = function(x) 2 * x

overhead = list("Baseline" = 300 * 1e-9
               , "Serialize" = 8000 * 1e-9
               , "Fork" = 1.5 * 1e-3
               , "Startup" = 150 * 1e-3
               )

overhead = unlist(overhead)

#overhead = list("Baseline" = quote(twox(10))
#               , "Serialize" = quote(serialize(10, NULL))
#               #, "Fork" = expression(
#               #                 mcparallel(twox(10))
#               #                 mccollect()
#               #                 )
#               )
#
#overhead = lapply(overhead, microbenchmark)
#
#overhead["Startup"] = 150 * 1e-3
#overhead = do.call(c, overhead)

pdf("overhead.pdf", height = 4)
barplot(overhead
        , log = "y"
        #, cex.names = 0.7
        , main = "fixed sources of overhead"
        , ylab = "seconds"
        , ylim = c(1e-7, 1)
        )
dev.off()
