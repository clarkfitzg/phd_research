source("predictY.R")

Rprof("predictY_prof.out")

predictY(as.integer(1e5), yfile = "Ysmall.csv")

Rprof(NULL)
