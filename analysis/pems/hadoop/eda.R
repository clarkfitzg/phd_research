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

# read.table behaves differently from data.table here, so these values will
# change
FLOW2_INDEX = 7
OCC2_INDEX = 8

names(s1)[FLOW2_INDEX] = "flow2"
names(s1)[OCC2_INDEX] = "occ2"

flow2 = s1[, FLOW2_INDEX]
occ2 = s1[, OCC2_INDEX]

hist(occ2)

binned = cut(occ2, breaks = seq(0, 1, by = 0.1), right = FALSE)

table(binned)

# I want to randomly sample k points from each congestion area and plot
# them.

plot_k = function(grp, x = OCC2_INDEX, y = FLOW2_INDEX, k = 20)
{
    samp = grp[sample.int(nrow(grp), size = k), ]
    points(samp[, x], samp[, y])
}


samp_k = function(grp, k = 20)
{
    grp[sample.int(nrow(grp), size = k), ]
}


set.seed(934)
samp = by(s1, binned, samp_k)
samp = do.call(rbind, samp)

# A triangular FD actually seems quite reasonable in this case.
# The only concern is that variance is unequal: there's much greater
# variance around occupancy 0.3
plot(samp[, OCC2_INDEX], samp[, FLOW2_INDEX]
     , type = "p", xlab = "occupancy", ylab = "flow vehicles/30 sec")


# What does a smoothing spline look like?
############################################################

spline_samp = smooth.spline(samp[, OCC2_INDEX], samp[, FLOW2_INDEX]
                            , nknots = 9)

spline_full = smooth.spline(s1[, OCC2_INDEX], s1[, FLOW2_INDEX]
                            , nknots = 9)

x = data.frame(occ2 = seq(0, 1, length.out = 200))

psamp = predict(spline_samp, x)
lines(psamp$x, psamp$y, col = "blue")

pfull = predict(spline_full)
lines(pfull$x, pfull$y, col = "red")

# Probably the spline is 'wavy' because it's fitting to these integer
# values.
# But by the time the occupancy is 0.4 they both look well approximated by
# the linear fit.


# How about a piecewise linear fit?
library(segmented)


fit = lm(flow2 ~ occ2, samp)
fitp = segmented(fit, seg.Z = ~occ2, psi = list(occ2 = c(0.2, 0.4))
    #, control = seg.control(
                 )

lines(x$occ2, predict(fitp, x), col = "blue")


fitfull = lm(flow2 ~ occ2, s1)

fitpfull = segmented(fitfull, seg.Z = ~occ2, psi = list(occ2 = c(0.2, 0.4))
    #, control = seg.control(
                 )

# This is appealing, seems to be doing something reasonable.
lines(x$occ2, predict(fitpfull, x), col = "blue")

# What are these U's and psi's?
sf = summary(fitpfull) 

# psi coef not correct here.
sf$coefficients

# use this one
fitpfull$psi

# So we want to make a data frame with all the relevant interesting
# parameters, including standard error. There's no reason we can't do every
# lane also, or at least the first 3.
# We can also throw out those that have all zeros, or with various errors.
data.frame(station = 
    , lane_number = 
    , n_total = 
    , n_high_density = 
    , r_squared = sf$r.squared
    , break1 = 
    , break2 = 
    , slope1 = 
    , slope2 = 
    , slope3 = 
    , seb1 = 
    , seb2 = 
    , ses1 = 
    , ses2 = 
    , ses3 = 
    )
