`ugh<-` = function(., ..., value)
{
    call = sys.call()
    env = parent.frame()
    symbols = lapply(call[-c(1, 2, length(call))], as.character)
    for(i in seq_along(symbols)){
        assign(symbols[[i]], value[[i]], env)
    }
}

. = NULL
ugh(., a, b, c) <- list(1, 2, 3)
