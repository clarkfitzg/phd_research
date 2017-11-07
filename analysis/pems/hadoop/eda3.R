# Mon Nov  6 07:52:15 PST 2017
#
# Looking at the results of the kernel based clustering.

library(cluster)


d = read.table("~/data/pems/fd_inner.txt")

dm = as.matrix(d)

# Scaling it into a correlation matrix
dcor = dm
N = nrow(d)
for(i in 1:N){
    for(j in 1:N){
        dij = dm[i, j] / sqrt(dm[i, i] * dm[j, j])
        if(is.na(dij)) stop()
        dcor[i, j] = dij
    }
}


sum(is.na(dm))

sum(is.na(dcor))

hist(diag(d3))


# Don't know what's going on. Why are values of dcor NA?





# They're almost all the same :)
hist(dcor[dcor > 0.5])

N2 = sum(is.na(dcor[1, ]))

d2 = dcor[!is.na(dcor)]

# Becomes a measure of dissimilarity
D = as.dist(1 - dcor)

D[is.na(D)] = NULL

pam1 = pam(D, 2)
