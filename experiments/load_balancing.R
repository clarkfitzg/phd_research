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


# New algorithm, pairwise exchanges using Karmarkar-Karp
pairwise_exchange = function(tasktimes, w)
{
}


# New algorithm, try to completely fill up workers first plus an epsilon
full_plus_epsilon = function(tasktimes, w
        , epsilon = min(tasktimes)
        )
{
    full_plus_epsilon = sum(tasktimes) / w + epsilon
    workertimes = rep(0, w)
    for(tm in tasktimes){
        newtimes = workertimes + tm
        idx = which(newtimes < full_plus_epsilon)[1]
        if(length(idx) == 0){
            # Cannot keep the size of any workers under full_plus_epsilon
            # Fall back to greedy algorithm
            idx = which.min(workertimes)
        }
        workertimes[idx] = workertimes[idx] + tm
    }
    workertimes
}


# make sure these algorithms work correctly
tt_hard_1 = c(2, 2, 2, 3, 3)
tt_hard_2 = c(8, 7, 6, 5, 4)

full_plus_epsilon(tt_hard_1, 2L)
greedy(tt_hard_1, 2L)

full_plus_epsilon(tt_hard_2, 2L)
greedy(tt_hard_2, 2L)


# Comparing the performance
############################################################

maxtime = function(f, tt, w){
    times = lapply(tt, f, w = w)
    sapply(times, max)
}


generate_times = function(ntasks = 20L, w = 2L, random_gen = runif)
{
    out = random_gen(ntasks)
    # Normalize so 1 is the ideal cost
    out = out * w / sum(out)
    sort(out, decreasing = TRUE)
}


compare = function(w = 4L, reps = 100L, ...
        , funcs = list(greedy, full_plus_epsilon))
{
    tt = lapply(seq(reps), generate_times, w = w, ...)
    results = lapply(funcs, maxtime, tt = tt, w = w)
    results = as.data.frame(results)
}


set.seed(23480)
out = compare(reps = 1000L)

# Positive delta shows that the first approach (greedy) is marginally better in this case.
delta = out[, 1] - out[, 2]
hist(delta)

t.test(delta)

table(sign(delta))

set.seed(901873)
out = compare(reps = 1000L, random_gen = function(n) seq(n) + runif(n))

# For this more skew data the new algorithm does better.
# This suggests that the new algorithm is more robust.

# To compare numbers I'll need to get the scaling right.
# What we really care about is relatively how far away we are from the lower bound.
# I.e. one algorithm is 1.05 times what the lower bound is.
# We can get this easily by scaling the task times so the lower bound is 1.

# What is a typical distribution of group sizes?
# The PEMS data has uniform group sizes.
# Often I see something that looks an exponential decay, with a long tail.


