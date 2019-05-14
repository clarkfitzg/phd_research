# Fri May 10 17:19:10 PDT 2019
#
# How to balance n tasks among w workers such that we minimize the time that all workers are finished?

# Assume that tasktimes are sorted in decreasing order.

library(lattice)


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
        if(is.na(idx)){
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

# Test it out
t0 = generate_times()

#compare = function(w = 4L, reps = 100L, ...
#        , funcs = list(greedy, full_plus_epsilon))
#{
#    tt = replicate(reps, generate_times(w = w, ...))
#    results = lapply(funcs, maxtime, tt = tt, w = w)
#    results = as.data.frame(results)
#    unname(results)
#}

skewgen = function(n) seq(n) + runif(n)

set.seed(23480)
w = 4L
tt = replicate(1000L, generate_times(w = w, random_gen = skewgen), simplify = FALSE)

fnames = c("greedy", "full_plus_epsilon")
funcs = lapply(fnames, get)
results = lapply(funcs, maxtime, tt = tt, w = w)
results = as.data.frame(results)
names(results) = fnames




delta = results[, 1] - results[, 2]
hist(delta)

t.test(delta)

table(sign(delta))

# Greedy and new approach are the same thing for uniform data.
# For more skewed data the new algorithm does better.
# This suggests that the new algorithm is more robust.

# To compare numbers I'll need to get the scaling right.
# What we really care about is relatively how far away we are from the lower bound.
# I.e. one algorithm is 1.05 times what the lower bound is.
# We can get this easily by scaling the task times so the lower bound is 1.

# What is a typical distribution of group sizes?
# The PEMS data has uniform group sizes.
# Often I see something that looks an exponential decay, with a long tail.

sim_groups = function(ngroups
        , fixed_part = exp(seq(from=1, to=4, length.out = ngroups))
        , random_part = runif(ngroups)
        )
{
    out = fixed_part + random_part
    out = out / sum(out)
    sort(out, decreasing = TRUE)
}


# I want a grid that shows relative performance of the algorithms,
# with workers on one axis, and number of groups on the other.

times = expand.grid(w = 2^(1:7), g = as.integer(exp(2:8)))
times$workers = as.factor(times$w)
times$groups = as.factor(times$g)

compare = function(w, g, reps = 100L, baseline = greedy, competitor = full_plus_epsilon)
{
    tt = replicate(reps, sim_groups(g), simplify = FALSE)

    t_comp_all = lapply(tt, competitor, w = w)
    t_comp = sapply(t_comp_all, max)

    if(is.null(baseline))
    {
        w * mean(t_comp)
    } else {
        t_baseline_all = lapply(tt, baseline, w = w)
        t_baseline = sapply(t_baseline_all, max)

        delta = t_comp - t_baseline
        #browser()
        w * mean(delta)
    }
}

# Test
compare(w = 3, 16)

times$delta = runif(nrow(times))

set.seed(24890)
times$delta = mapply(compare, times$w, times$g)
times$full_plus_epsilon = mapply(compare, times$w, times$g
        , MoreArgs = list(baseline = NULL))

pdf("greedy_load_balancing_group_by_compare.pdf")
levelplot(delta ~ workers * groups, data = times
          , main = "Improvement relative to baseline")
dev.off()

pdf("greedy_load_balancing_group_by_relative_to_ideal.pdf")
levelplot(full_plus_epsilon ~ workers * groups, data = times
          , main = "Performance relative to lower bound")
dev.off()


hist(times$delta)
