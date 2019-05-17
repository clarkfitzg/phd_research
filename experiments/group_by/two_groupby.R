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


# Put groups on the 'best' workers, starting with the largest groups and without exceeding a balanced load by epsilon.
# The best workers are those that have relatively more of the same second group already on them.
# Returns an integer vector the same length as P1 that assigns each group to one of the w workers.
first_group = function(P, w)
{
    P1 = rowSums(P)
    P2 = colSums(P)

    epsilon = min(P1)
    full_plus_epsilon = sum(P) / w + epsilon
    avg_load = sum(P) / w

    # These get updated as the assignments are made
    assignments = rep(NA, length(P1))
    times = rep(0, w)

    for(idx in order(P1, decreasing = TRUE)){
        tm = P1[idx]
        newload = P[idx, ]
        g2_loads = worker_g2_loads(assignments, P, w, avg_load)
        best_worker = find_best_worker(newload, g2_loads, times, epsilon, avg_load)
        assignments[idx] = best_worker
        times[w] = times[w] + tm
    }

    assignments
}


# This computes the load on each worker if the remaining groups of data were distributed evenly 
# according to the space each worker has available.
worker_g2_loads = function(assignments, P, w, avg_load)
{
    free_idx = is.na(assignments)

    # Balance the remainder of the unassigned load according to the relative space each worker has available.
    unassigned = colSums(P[free_idx, , drop = FALSE])

    # Scale the unassigned such that it sums to 1
    unassigned = unassigned / sum(unassigned)

    loads = vector(w, mode = "list")
    for(worker in seq(w)){
        load_idx = assignments[!free_idx] == worker
        load = colSums(P[load_idx, , drop = FALSE])
        free = avg_load - sum(load)
        if(0 < free){
            # Assign weight accordingly. 
            # TODO: This may "overassign" some of the free workers, but I'm not too worried about it.
            load = load + free * unassigned
        }
        loads[[worker]] = load
    }
    loads
}


scaled_similarity = function(x, y)
{
    x = x / sqrt(sum(x^2))
    y = y / sqrt(sum(y^2))
    sum(x * y)
}


find_best_worker = function(newload, g2_loads, times, epsilon, avg_load)
{
    candidates = times + newload < avg_load + epsilon

    # Corner case is when they all exceed it
    if(!any(candidates)) return(which.min(times))

    scores = sapply(g2_loads[candidates], scaled_similarity, y = newload)

    which(candidates)[which.max(scores)]
}


# Actually try it out
############################################################

# Numbers of groups
g1 = 20
g2 = 15
w = 3

set.seed(32180)
P = matrix(runif(g1 * g2), nrow = g1)

g1_assign = first_group(P, w)

P1 = rowSums(P)

# Did it do a reasonable load balancing?
# Nope!
tapply(P1, g1_assign, sum)

# Numbers should be around:
sum(P1) / w
