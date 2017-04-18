# Rough timings, based on various experiments. Units are seconds

overhead = list("simple_function_call" = 300 * 1e-9
               , "serialize_local_socket" = 8000 * 1e-9
               , "fork_evaluation" = 1.5 * 1e-3
               , "start_R_interpreter" = 150 * 1e-3
               )

overhead = do.call(c, overhead)

pdf("overhead.pdf", height = 4)
barplot(overhead
        , log = "y"
        , cex.names = 0.7
        , main = "fixed sources of overhead"
        , ylab = "seconds"
        , ylim = c(1e-7, 1)
        )
dev.off()
