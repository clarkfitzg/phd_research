#!/usr/bin/env Rscript
writeLines("\n\n\nBEGIN R SCRIPT", stderr())

infile = file("stdin")
tbl = read.table(infile)

msg = paste(c("tbl dimensions:", dim(tbl)), collapse = " ")
writeLines(msg, stderr())

s = split(tbl, tbl[, 1])

ans = lapply(s, function(ss){
    data.frame(ss[1, 1], nrow(ss))
})

ans = do.call(rbind, ans)

write.table(ans, stdout(), sep = "\t"
            , col.names = FALSE, row.names = FALSE)

writeLines("END R SCRIPT\n\n\n", stderr())
