# Wed Jan 25 10:03:28 PST 2017
#

library(future)

# I'm running on a machine with 4 cores, but it would be great if all 8
# downloads could happen at the same time. This doesn't happen because it's
# blocking.
plan("multicore", workers = 8)

download = function(x) download.file(x[1], x[2])

urls = list(c("https://github.com", "a.html")
            , c("https://google.com", "b.html")
            , c("https://yahoo.com", "c.html")
            , c("https://twitter.com", "d.html")
            , c("https://reddit.com", "e.html")
            , c("https://apple.com", "f.html")
            , c("https://microsoft.com", "g.html")
            , c("https://oracle.com", "h.html")
            )

future_lapply(urls, download)
