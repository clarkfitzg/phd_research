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
    sample(char, size = nchar_x, replace = TRUE)
}

# Parameter names correspond to those in chartr
# Repeat the timings `ntimes` and keep the `nkeep` fastest.
experiment = function(n_old, len_x, nchar_x, ntimes = 15L, nkeep = 10L, char = letters2)
{
    old = sample(char, size = n_old)
    new = sample(char, size = n_old)
    x = replicate(len_x, random_string(nchar_x, char))
    tm = microbenchmark(chartr(old, new, x), ntimes = ntimes)
    times = sort(tm$time)
    times = time[seq(nkeep)]
    data.frame(n_old = n_old, len_x = len_x, nchar_x = nchar_x, time = times)
}

params = 
