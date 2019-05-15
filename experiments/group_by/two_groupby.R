# Wed May 15 12:18:16 PDT 2019
#
# I'm on the fence about whether or not to bother actually doing this experiment.
#
# How much time can we save by arranging the groups so that we minimize transfer time?
# Through this little experiment we can have some idea of how well it works.
#
# I don't really plan on implementing this in the scheduler, since I think it's too specific.

# These are the unit costs in terms of the size of the group / data to compute the group by's and to transfer data.
# They're only important relative to each other, which is why I put them in this form.
cost = list(gb1 = 1, gb2 = 1, transfer = 1)

# The best case scenario for the speedup is if the transfer goes from transferring every data element to transferring nothing at all, which would be a speedup of: 
(cost$gb1 + cost$gb2 + cost$transfer) / (cost$gb1 + cost$gb2)

# It's more likely to me that the group by computations take longer than the transfers, which means that this number would be even smaller.
# There's also the case of a hierarchy of workers, where transfers between different groups of workers take much longer than among the same group of workers.

# Numbers of groups
g1 = 20
g2 = 15
w = 3

set.seed(32180)
P = matrix(runif(g1 * g2), nrow = g1)

P1 = rowsum(P)
P2 = colsum(P)
