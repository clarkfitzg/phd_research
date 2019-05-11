# Fri May 10 17:19:10 PDT 2019
#
# How to balance n tasks among w workers such that we minimize the time that all workers are finished?


# Standard greedy algorithm
greedy = function(p, w)
{
    #schedule = lapply(seq(w), numeric)
    times = rep(0, w)
    for(tm in p){
        idx = which.min(times)
        times[idx] = times[idx] + tm
    }
    times
}


# Greedy with pairwise exchanges using Karmarkar-Karp
greedy_pairs = function(p, w)
{
}


# My algorithm, try to fill up workers first plus an epsilon
full_plus_epsilon = function(p, w)
{
    times = rep(0, w)
    for(tm in p){
    }
    times

}

