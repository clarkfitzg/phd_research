# Mon Nov  6 07:52:15 PST 2017
#
# Looking at the results of the kernel based clustering.

library(cluster)

source("tools.R")

d = read.table("~/data/pems/fd_inner.txt")

dm = as.matrix(d)

# From histogram some of these values are way out of line. We'll chop off
# the outliers because it's likely due to faulty sensors rather than
# any interesting phenomenon.

# These actually represent the squared function norms
norms = diag(dm)

# Chop off the upper and lower 1 percent
hilow = quantile(norms, probs = c(0.01, 0.99))
keepers = (hilow[1] < norms) & (norms < hilow[2])

# Sanity check, should be about 0.98
mean(keepers)

dm = dm[keepers, keepers]

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

fd = read.table("~/data/pems/fdclean.tsv", header = TRUE)

# match clusters to stations
c2 = clusters[as.character(fd$station)]
fd$cluster = c2

# Remove those that didn't match
fd = fd[!is.na(fd$cluster), ]

# What do the representative FD's look like?
# These are the "median" cluster for each group. Whatever that means :)
pam1$medoids

cluster1 = fd[fd$station == as.integer(pam1$medoids[1]), ]

cluster2 = fd[fd$station == as.integer(pam1$medoids[2]), ]

plot(c(0, 1), c(0, max(cluster1$lefty, cluster2$lefty)), type = "n"
     , main = "Cluster medoids"
     , xlab = "occupancy"
     , ylab = "flow (veh / 30 sec)")
plotfd(cluster1, lty = 2)
plotfd(cluster2, lty = 1)
legend("topright", legend = c("Cluster 1", "Cluster 2"), lty = c(2, 1))

# Cool!
# The most obvious feature is that one function is concave while the other
# is not.

c2 = fd$cluster == 2

# This is only 0.84, so concavity mostly corresponds to the clustering, but
# not exactly.
mean(fd$right_convex == c2)
