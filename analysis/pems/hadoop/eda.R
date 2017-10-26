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

# It doesn't seem that data.table can read from stdin. Then I'm left with
# read.table. Could pass more args here for efficiency.
s1 = read.table("~/data/two_stations/000014_0.gz")
# read.table behaves differently from data.table here, so these values will
# change
FLOW2_INDEX = 7
OCC2_INDEX = 8
HI_OCC_THRESHOLD = 0.5
names(s1)[FLOW2_INDEX] = "flow2"
names(s1)[OCC2_INDEX] = "occ2"

flow2 = s1[, FLOW2_INDEX]
occ2 = s1[, OCC2_INDEX]

hist(occ2)

binned = cut(occ2, breaks = seq(0, 1, by = 0.1), right = FALSE)

table(binned)

# I want to randomly sample k points from each congestion area and plot
# them.

samp_k = function(grp, k = 12)
{
    grp[sample.int(nrow(grp), size = k), ]
}


set.seed(934)
samp = by(s1, binned, samp_k)
samp = do.call(rbind, samp)

# A triangular FD actually seems quite reasonable in this case.
# The only concern is that variance is unequal: there's much greater
# variance around occupancy 0.3
# And wow- when I look at a different station I see _much_ more variability
# in the fd
plot(samp[, OCC2_INDEX], samp[, FLOW2_INDEX]
     , type = "p", xlab = "occupancy", ylab = "flow vehicles/30 sec")


# What does a smoothing spline look like?
############################################################

spline_samp = smooth.spline(samp[, OCC2_INDEX], samp[, FLOW2_INDEX]
                            , nknots = 9)

spline_full = smooth.spline(s1[, OCC2_INDEX], s1[, FLOW2_INDEX]
                            , nknots = 9)

x = data.frame(occ2 = seq(0, 1, length.out = 200))

psamp = predict(spline_samp, x[, 1])

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

# What are these U's and psi's?
sf = summary(fitpfull) 

# psi coef not correct here.
sf$coefficients

# use this one
fitpfull$psi




# This is appealing, seems to be doing something reasonable.
# EDIT: Less so for the other of the two stations.
lines(x$occ2, predict(fitpfull, x), col = "blue")

# What does the actual data look like in region of high occupancy?
hiocc = s1[s1$occ > HI_OCC_THRESHOLD, ]

with(hiocc, plot(occ2, flow2))

lm_hi = lm(flow2 ~ occ2, hiocc)

# At least the linear fit passes through (1, 0)
abline(lm_hi)

seg_hi = segmented(lm_hi, seg.Z = ~occ2, psi = list(occ2 = c(0.7, 0.9)))

# Interesting result
lines(x$occ2, predict(seg_hi, x), col = "blue")


# I can also enforce the constraint that it runs through the point (1, 0)
# by removing the intercept in the model
lm_hi2 = lm(flow2 ~ I(occ2 - 1) - 1, hiocc)
# -20.49

lines(x$occ2, predict(lm_hi2, x), col = "red")

# What's the slope in mph? Michael says it should be consistent between -10
# and - 15 mph.
vehicle_length = 15
ft_per_mile = 5280
vehicle_mile = ft_per_mile / vehicle_length

# This slope is -7 mph. Doesn't exactly match up. Possibly because of
# various types of traffic?
mph = 120 * coef(lm_hi2) / vehicle_mile

# Will a robust linear model help at all?
rlm_hi2 = MASS::rlm(flow2 ~ I(occ2 - 1) - 1, hiocc)
# -20.15
# No, it's pretty much the same.

# Here's an idea- Fit the areas as follows:
#
# (0, 0.1) with a line passing through the origin
# (0.2, 0.5) with a standard linear model with intercept
# (0.5, 1.0) with a line through (1, 0)
#
# The area between (0.1, 0.2) is ambiguous because traffic may be free
# flowing or congested. We can extend the fundamental diagram to this area by
# just taking the intersection of the first two lines. Similarly we can
# (probably) make the fd continuous at the right knot by taking the
# intersection of the second and third lines. 
#
# If we do all of this the complete fd is defined by two points between 
# (0, 1). => Four numbers... I'll just store the parameters for the models
# I find, because that's easiest.

LEFT_RIGHT = 0.1
MIDDLE_LEFT = 0.2
MIDDLE_RIGHT = 0.5
RIGHT_LEFT = 0.5

left_data = s1[s1$occ2 <= LEFT_RIGHT, ]
left_fit = lm(flow2 ~ occ2 -1, left_data)

middle_data = s1[(MIDDLE_LEFT <= s1$occ2) & (s1$occ2 < MIDDLE_RIGHT), ]

middle_fit = lm(flow2 ~ occ2, middle_data)

right_data = s1[RIGHT_LEFT <= s1$occ2, ]
right_fit = lm(flow2 ~ I(occ2 - 1) - 1, right_data)

# This looks reasonable for both 000016 and 000014. Quite interesting that
# one is convex and one is concave at the 2nd knot.
# IDEA: This diagram also implies a maximum flow. It would be interesting
# to compare real max flows with the theoretical max flow.
plot(samp[, OCC2_INDEX], samp[, FLOW2_INDEX]
     , type = "p", xlab = "occupancy", ylab = "flow vehicles/30 sec")
abline(left_fit)
abline(middle_fit)
lines(x$occ2, predict(right_fit, x))

abline(middle_fit)


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
