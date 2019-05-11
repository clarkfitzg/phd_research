# Fri May 10 17:19:10 PDT 2019
#
# How to balance n tasks among w workers such that we minimize the time that all workers are finished?


# Standard greedy algorithm
greedy = function(tasktimes, w)
{
    #schedule = lapply(seq(w), numeric)
    workertimes = rep(0, w)
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


# My algorithm, try to fill up workers first plus an epsilon
full_plus_epsilon = function(tasktimes, w)
{
    # Think more about this.
    epsilon = tasktimes[length(tasktimes) - w]

    workertimes = rep(0, w)
    for(tm in tasktimes){
    }
    workertimes
}

