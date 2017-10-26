# Thu Oct 26 09:31:04 PDT 2017
#
# Going through some of the questions that M. Zhang and I talked about on
# Tuesday.
#
# Still thinking that we could cluster different types of stations. One way
# to do this is to take the FD representing the station and look at the
# distance between functions as the metric for clustering. The triangular
# diagram is too rigid in this case, so we could fit some kind of smoother
# or piecewise linear model to the data.
# 
# To see how to do this we can load the data in and look at the histogram,
# see if we have enough observations in areas of high occupancy.
#
# Another task is to look at the capacities. One could define this as the
# max flow that was sustained for at least 1 minute. I queried the maxs by
# station in SQL previously.

s1 = read.table("~/data/two_stations/000014_0.gz")

flow2 = s1[, 7]
occ2 = s1[, 8]

binned = cut(occ2, breaks = seq(0, 1, by = 0.1), right = FALSE)

table(binned)
