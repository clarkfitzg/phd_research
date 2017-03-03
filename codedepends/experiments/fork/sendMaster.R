# Thu Mar  2 16:52:31 PST 2017
#
# Playing around with parallel low level functions to see how I can manage
# an event loop.

library(parallel)

child = parallel:::mcfork()

mcparallel(sendMaster(pi))

mccollect()
