library(autoparallel)

files = list.files(pattern = "^script[0-9]+.R")

lapply(files, autoparallel)
