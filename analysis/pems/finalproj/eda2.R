library(akima)

source("helpers.R")

load("hwy.rda")


# Where are the sensors spaced geographically?
# Most have less than 1/2 mile
a = sort(unique(hwy$Abs_PM))
hist(diff(a), freq = FALSE)

time_pts = seq(0, 24, by = 1/120)

mile_pts = seq(round(min(hwy$Abs_PM)), round(max(hwy$Abs_PM)), by = 0.5)

# Now lets see if we can get it interpolated.
# The linear version is CPU expensive- takes ~ 5 minutes
hwyint = akima::interp(x = hwy$hour, y = hwy$Abs_PM, z = hwy$mean_occ
                     , xo = time_pts, yo = mile_pts
                     #, linear = FALSE
                     , duplicate = "mean"
                     )

z = hwyint$z

z[z > 0.5] = 0.5


# TODO- use lattice for better comparison with the others
png("I80_occ_linear_interp.png"
               , width = 1080
               , height = 1080
               )

image(z, col = gray((0:32) / 32))

dev.off()
