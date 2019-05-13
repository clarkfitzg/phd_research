# Fri May 10 17:19:10 PDT 2019
#
# How to balance n tasks among w workers such that we minimize the time that all workers are finished?

# Assume that tasktimes are sorted in decreasing order.


# Standard greedy algorithm
greedy = function(tasktimes, w, workertimes = rep(0, w))
{
    for(tm in tasktimes){
        idx = which.min(workertimes)
        workertimes[idx] = workertimes[idx] + tm
    }
    workertimes
}


# Greedy with pairwise exchanges using Karmarkar-Karp
greedy_pairs = function(tasktimes, w)
{
}


# New algorithm, try to fill up workers first plus an epsilon
full_plus_epsilon = function(tasktimes, w
        , epsilon = min(tasktimes)
        )
{
    full_plus_epsilon = sum(tasktimes) / w + epsilon
    workertimes = rep(0, w)
    for(tm in tasktimes){
        newtimes = workertimes + tm
        idx = which(newtimes < full_plus_epsilon)[0]
        workertimes[idx] = workertimes[idx] + tm
    }
    workertimes
}

