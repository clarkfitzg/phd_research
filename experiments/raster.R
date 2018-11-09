# Thu Oct 12 09:07:20 PDT 2017

# Responding to an email from Maegen Simmonds.
# 30m raster data of California

n = 4.239707e+11 / 30^2
nregions = 10
nowners = 5

# Generate some data
set.seed(3280)
d = data.frame(region = sample.int(nregions, size = n, replace = TRUE)
               , owner = sample.int(nowners, size = n, replace = TRUE)
               )

table(d[1:100, ])

# 13 minutes
system.time(result <- table(d))
