# Tue Jul 19 09:41:31 PDT 2016
# Starting with the simplest possible things

library(sparkapi.ddR)
#library(ddR)

useBackend(Spark)

a = dlist(1:10, letters)

b = collect(a)
