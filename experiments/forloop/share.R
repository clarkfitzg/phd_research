# Mon Apr 30 17:34:17 PDT 2018
#
# Use bigmemory for a shared data structure that all workers can access.


library(parallel)

library(bigmemory)

n = 20
p = 10
nworkers = 2
bfile = "x.bin"
dfile = "x.bin.desc"

x = big.matrix(n, p, backingfile = bfile, descriptorfile = dfile)
dx = describe(x)

cls = makeCluster(nworkers, "PSOCK")

# Prepare the workers
clusterEvalQ(cls, library(bigmemory))
clusterExport(cls, c("p", "bfile", "dfile", "dx"))

clusterEvalQ(cls, {x <- attach.big.matrix(dfile)
    NULL})


work = function(idx)
{
    for(i in idx){
        for(j in seq(p))
            x[i, j] = (i-1)*p + j
    }
}

indices = splitIndices(n, nworkers)

parLapply(cls, indices, work)

# Seems to work fine.
x2 = as.matrix(x)

# How about if I do it from forked processes?

stopCluster(cls)

work3 = function(idx)
{
    for(i in idx){
        for(j in seq(p))
            x[i, j] = 10*(i-1)*p + j
    }
}

mclapply(indices, work3)

# Yes, also works fine. So there's no issue with the inherited data
# structures.
x3 = as.matrix(x)


n = 1e6
p = 1e3
y = big.matrix(n, p, init = 1, backingfile = "y.bin", descriptorfile = "y.bin.desc")
