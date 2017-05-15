library(MASS)

set.seed(8420)

# For 10 months of data I expect this many lines:
10 * 30 * 24 * 60 * 2
# Nearly 1 million

s1 = read.table("~/data/station_400400.csv", sep = ",", row.names = NULL)


picks = sample(seq(nrow(s1)), size = 300)

s1_sample = s1[picks, ]

pdf("occ_flow_with_sample.pdf")
with(s1_sample, plot(occupancy2, flow2
                     , main = "300 randomly sampled points"
                     , xlab = "occupancy"
                     , ylab = "flow"))
dev.off()


# Only 5% of observations high occupancy
highocc = s1$occupancy2 > 0.15

s_high = s1[highocc, ][sample(sum(highocc), size = 300), ]

with(s_high, plot(occupancy2, flow2
                     , main = "300 randomly sampled points from high occupancy"
                     , xlab = "occupancy"
                     , ylab = "flow"))

# Some very clear patterns in the residual plots
# Suggest that it might be better to use count regression here
fit = rlm(flow2 ~ occupancy2, data = s1[highocc, ])

# Std. Error for slope is under 0.1

png("residuals.png")
plot(fit, which = 3)
dev.off()

fit_small = rlm(flow2 ~ occupancy2, data = s_high)
# Std. Error for slope is greater than 1.

# Having the small standard errors, ie. near 0.1 instead of 1 will be
# helpful when using this as preprocessing for more sophisticated
# inference. Basically we already know the slope of the line to within a
# std error of 1 or 2 before we start.

fit_lm = lm(flow2 ~ occupancy2, data = s1[highocc, ])

# This shows that the lm and rlm estimates differ.
