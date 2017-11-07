# Mon Nov  6 07:52:15 PST 2017
#
# Looking at the results of the kernel based clustering.

library(cluster)


d = read.table("~/data/pems/fd_inner.txt")

dm = as.matrix(d)

nonzero = diag(dm) != 0

dm = dm[nonzero, nonzero]

# Scaling a similarity matrix into a correlation matrix
dcor = dm
N = nrow(dm)
# This is a nice use case for when a for loop is easy to write, but an
# apply function would be awkward.
# I didn't know why I was getting NA's, so I wanted to stop and check when
# it occurs.
for(i in 1:N){
    for(j in 1:N){
        dij = dm[i, j] / sqrt(dm[i, i] * dm[j, j])
        if(is.na(dij)) stop()
        dcor[i, j] = dij
    }
}

# Becomes a measure of dissimilarity
D = as.dist(1 - dcor)


pam1 = pam(D, 2)

clusters = pam1$clustering

table(clusters)

# What do these representative FD's look like?
pam1$medoids

fd = read.table("~/data/pems/fdclean.tsv", header = TRUE)
fd = fd[nonzero, ]

# match clusters to stations
c2 = clusters[as.character(fd$station)]
fd$cluster = c2

# The representative clusters
