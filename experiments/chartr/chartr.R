# Fri Jan  4 05:51:34 PST 2019
#
# I'm looking for an example of string processing where I can precisely
# estimate the time required to do it all. `gsub` is no good because of the
# complexities of regular expression.
#
# chartr substitutes one character for another. I expect that the run time
# for this function is linear in: 
#
# the number of lookups X length of string vector to translate X size of individual strings

# Side Note:
# Hmm, when I do microbenchmark() on very simple experssions the first time
# is much slower than the others. That suggests I should ignore the larger
# ones.

library(microbenchmark)
library(parallel)
library(Unicode)


letters2 = c(letters, LETTERS)

random_string = function(nchar_x, char)
{
    out = sample(char, size = nchar_x, replace = TRUE)
    paste(out, collapse = "")
}

if(FALSE)
{

# Parameter names correspond to those in chartr
# Repeat the timings `ntimes` and keep the `nkeep` fastest.
experiment = function(n_chars_replace, len_x, nchar_x, ntimes = 15L, nkeep = 10L, char = letters2)
{
    old = sample(char, size = n_chars_replace)
    old = paste(old, collapse = "")
    new = sample(char, size = n_chars_replace)
    new = paste(new, collapse = "")
    x = replicate(len_x, random_string(nchar_x, char))
    #expr = quote(chartr(old, new, x))
    bm = microbenchmark(chartr(old, new, x), times = ntimes)
    times = sort(bm$time)
    times = times[seq(nkeep)]
    data.frame(n_chars_replace = n_chars_replace, len_x = len_x, nchar_x = nchar_x, time = times)
}

# Test it out
experiment(10, 10000, 20)

params = expand.grid(n_chars_replace = c(1, 2, 5, 10, 20, 40)
    , len_x = 100 * seq(10)
    , nchar_x = 20 * seq(10)
    )

args = do.call(list, params)
args$f = experiment

system.time(
raw_result <- do.call(Map, args)
)

result = do.call(rbind, raw_result)

fit = lm(time ~ n_chars_replace * len_x * nchar_x, data = result)

summary(fit)

# R^2 of 0.97, nice.
# The interaction term is most significant, just as I expected.

# The QQ plot shows heavy tails.
# I guess that's the way it goes- things can be linear but not
# necessarily normal.

# There's a linear term in the length of x.
# This makes sense, because R has to allocate a new vector of length x to
# hold the result, and this should take linear time.
# I forgot about this with my initial time estimate.

fit1b = lm(time ~ len_x + len_x:nchar_x + n_chars_replace:len_x:nchar_x, data = result)
summary(fit1b)

# What about the linear term in len_x:nchar_x ?
# Why should this term appear?
# It's an order of magnitude smaller than the len_x term.
# That's ok, because it's a 'squared' term.

# If I exclude it from the model then R^2 drops way down from 0.97 to
# 0.82, which means that it's still pretty important.

fit2 = lm(time ~ len_x + n_chars_replace:len_x:nchar_x, data = result)
summary(fit2)


fit1c = lm(time ~ len_x:nchar_x + n_chars_replace:len_x:nchar_x, data = result)
summary(fit1c)

} # End if FALSE


# When I exclude the len_x term we still see an R^2 of 0.97.
# Together this means that len_x is not that important if we know
# len_x:nchar_x.
# Why should this be?
# It makes perfect sense if we were manually allocating space for the
# actual physical result, meaning the C level char arrays, because we need
# to allocate space linear in len_x:nchar_x.
# Furthermore, len_x:nchar_x is the actual _size_ of the input data in bytes, which is surely important.

# I guess that R _would_ have to allocate this space inside chartr, even if
# it ultimately stores the final result of strings using an integer lookup
# table.
# The reason is that chartr needs to actually do this low level
# manipulation _somewhere_. I can imagine various ways of doing it. One
# straightforward way is for each element of the vector, initialize a new C
# level character array with the contents of the old one, and then do the
# translation.

# Does R actually do this?
# Looking in main.c in the source for chartr we see loops over the elements
# with:
#       cbuf = CallocCharBuf(strlen(xi));
# Looking in R_ext/RS.hh we see that this does the memory allocation.
# So yes, it's doing what I expected, namely allocating memory to do the
# actual work at each iteration.

# In summary, the performance of chartr is best represented by fit1c.
# It's realistic to know all of the terms ahead of time to be able to estimate speed.

# Side note-
# It would also be good to profile this at the C level.

############################################################

# 2d plot for when parallelization is faster based on the arguments
# When is it faster to do parallel vs serial?
# How about for each number of cores?


uni = u_scripts("Common")[[1]]
uni = as.u_char(uni)
uni = as.integer(uni)
uni = intToUtf8(uni, multiple = TRUE)

# dashes specify ranges in chartr
uni = uni[uni != "-"]

# Check
random_string(10, uni)

# Start with 2 cores.
experiment_serial_parallel = function(n_chars_replace, data_size, nchar_x = 500L, len_x = data_size / nchar_x, mc.cores = 2L, char = uni)
{
    old = sample(char, size = n_chars_replace)
    old = paste(old, collapse = "")
    new = sample(char, size = n_chars_replace)
    new = paste(new, collapse = "")

# Fixes length mismatch. Not sure yet why it happens.
    len = min(nchar(old), nchar(new))
    old = substr(old, 1L, stop = len)
    new = substr(new, 1L, stop = len)

    x = replicate(len_x, random_string(nchar_x, char))
    #expr = quote(chartr(old, new, x))
    gc()
    time_serial = microbenchmark(chartr(old, new, x), times = 1L)$time
    time_parallel = microbenchmark(pvec(x, chartr, old = old, new = new, mc.cores = mc.cores), times = 1L)$time
    data.frame(n_chars_replace = n_chars_replace, data_size = data_size, len_x = len_x, nchar_x = nchar_x, time_serial = time_serial, time_parallel = time_parallel)
}

params = expand.grid(n_chars_replace = 200 * seq(10)
    , data_size = 2e4 * seq(20)
    )

args = do.call(list, params)
args$f = experiment_serial_parallel

system.time(
raw_result <- do.call(Map, args)
)

result = do.call(rbind, raw_result)

result$speedup = result$time_serial / result$time_parallel

# FINALLY! speedup > 1. I knew we'd get it eventually.
range(result$speedup)


# Maybe this means that we don't always _want_ to fuse vectorized
# statements. For example, we start with a small intermediate result, and
# then we call a fast function that produces a much larger result from the
# intermediate result. It may be faster to transfer the small intermediate
# result and call the fast function in serial than to transfer the larger
# object. 

# In theory we can use shared memory to avoid the transfer costs, but in
# practice R's copy on write semantics will get in the way.


# Plotting
############################################################

library(lattice)

image(result$data_size, result$n_chars_replace, result$speedup)

pdf("chartr_parallelism.pdf")

levelplot(speedup ~ data_size * n_chars_replace, result, at = c(-Inf, 0.7, 0.9, 1.1, 1.3, Inf)
          , main = "Speedup from parallelism in chartr"
          , xlab = "Size of data (bytes)"
          , ylab = "Number of characters to replace"
          )

dev.off()


fit_ser = lm(time_serial ~ data_size + n_chars_replace:data_size, data = result)
summary(fit_ser)

fit_par = lm(time_parallel ~ data_size + n_chars_replace:data_size, data = result)
summary(fit_par)

# Hmm. R^2 not as good for parallel model at 0.92.

