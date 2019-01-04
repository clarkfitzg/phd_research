# Fri Jan  4 05:51:34 PST 2019
#
# I'm looking for an example of string processing where I can precisely
# estimate the time required to do it all. `gsub` is no good because of the
# complexities of regular expression.
#
# chartr substitutes one character for another. I expect that the run time
# for this function is linear in both the lookup set of characters
# (length of 1st and 2nd args),
# and the number of characters to be translated (3rd arg).

# Side Note:
# Hmm, when I do microbenchmark() on very simple experssions the first time
# is much slower than the others. That suggests I should ignore the larger
# ones.

library(microbenchmark)

letters2 = c(letters, LETTERS)

random_string = function(nchar_x, char)
{
    out = sample(char, size = nchar_x, replace = TRUE)
    paste(out, collapse = "")
}

# Parameter names correspond to those in chartr
# Repeat the timings `ntimes` and keep the `nkeep` fastest.
experiment = function(n_old, len_x, nchar_x, ntimes = 15L, nkeep = 10L, char = letters2)
{
    old = sample(char, size = n_old)
    old = paste(old, collapse = "")
    new = sample(char, size = n_old)
    new = paste(new, collapse = "")
    x = replicate(len_x, random_string(nchar_x, char))
    expr = quote(chartr(old, new, x))
    tm = microbenchmark(list = list(expr), ntimes = ntimes)
    times = sort(tm$time)
    times = times[seq(nkeep)]
    data.frame(n_old = n_old, len_x = len_x, nchar_x = nchar_x, time = times)
}

# Test it out
experiment(10, 10000, 20)

params = expand.grid(n_old = c(1, 2, 5, 10, 20, 40)
    , len_x = c(1, 10, 100, 1000)
    , nchar_x = c(1, 10, 100, 500)
    )

args = do.call(list, params)
args$f = experiment

system.time(
raw_result <- do.call(Map, args)
)

result = do.call(rbind, raw_result)

fit = lm(time ~ n_old + len_x * nchar_x, data = result)

summary(fit)

# This is weird.
# The times are NOT as I expected.
# Aw, jeez. It's because microbenchmark is timing the expression ntimes.
# I passed that instead of `times` as the argument.
