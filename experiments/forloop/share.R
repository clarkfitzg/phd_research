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

cls = makeCluster(nworkers, "PSOCK")

# Prepare the workers
clusterEvalQ(cls, library(bigmemory))
clusterExport(cls, c("p", "bfile", "dfile"))
clusterEvalQ(cls, library(bigmemory))

clusterEvalQ(cls, x <- attach.big.matrix(dfile))


work = function(idx)
{
    for(i in idx){
        for(j in seq(p))
            x[i, j] = i*(p-1) + j
    }
}

indices = splitIndices(n, nworkers)

parLapply(cls, indices, work)
