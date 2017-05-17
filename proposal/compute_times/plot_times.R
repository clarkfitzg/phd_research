# Rough timings, based on various experiments. Units are seconds

overhead = list("Baseline" = 300 * 1e-9
               , "Serialize" = 8000 * 1e-9
               , "Fork" = 1.5 * 1e-3
               , "Startup" = 150 * 1e-3
               )
overhead = do.call(c, overhead)

pdf("overhead.pdf", height = 4)
barplot(overhead
        , log = "y"
        #, cex.names = 0.7
        , main = "fixed sources of overhead"
        , ylab = "seconds"
        , ylim = c(1e-7, 1)
        )
dev.off()
