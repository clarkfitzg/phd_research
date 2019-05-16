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
cost = list(gb1 = 1, gb2 = 1, transfer = 5)

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



# Put groups on the 'best' workers, starting with the largest groups and without exceeding a balanced load by epsilon.
# The best workers are those that have relatively more of the same second group already on them.
# Returns an integer vector the same length as P1 that assigns each group to one of the w workers.
first_group = function(P, w)
{
    P1 = rowsum(P)
    P2 = colsum(P)

    epsilon = min(P1)
    full_plus_epsilon = sum(P) / w + epsilon

    # These get updated as the assignments are made
    assignments = rep(NA, length(P1))
    times = rep(0, w)

    for(idx in order(P1, decreasing = TRUE)){
        tm = P1[idx]
        newload = P[idx, ]
        g2_loads = worker_g2_loads(assignments, P)
        w = find_best_worker(newload, g2_loads, times, epsilon)
        assignments[idx] = w
        times[w] = times[w] + tm
    }

    assignments
}


    # G2 starts out evenly distributed among workers.
    # This is necessary instead of zeros for how we'll balance based on inner products.
    #worker_g2_loads = lapply(seq(w), function(...) P2 / w)

worker_g2_loads = function(assignments, P)
{
}


