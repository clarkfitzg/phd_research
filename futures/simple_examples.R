# Mon Jan 16 11:03:39 PST 2017
# Experiments with the futures package

library("future")


slow1 = function(sleep = 5)
{
    Sys.sleep(sleep)
    1
}
