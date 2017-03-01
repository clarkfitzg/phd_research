two6 = TRUE
dt_seconds = 1
dx_feet = 88
plotname = "dx88.pdf"
totaltime = 0.1
miles = 1
ffspeed = 60
jam_density = 280
shock_speed = -10
library("RColorBrewer")
linefactory = function(slope, x0, y0) {
    intercept = y0 - slope * x0
    function(x) slope * x + intercept
}
if (two6) {
    dt_seconds = 0.3
    dx_feet = 26.4
    plotname = "dx26.pdf"
}
ntime = round(totaltime/dt)
x2 = 0.75 * miles/ffspeed
critical_density = -shock_speed * jam_density/(ffspeed - shock_speed)
firstcar = linefactory(ffspeed, 0, 0)
nojam = linefactory(shock_speed, 0, miles)
dt = dt_seconds/(60 * 60)
dx = dx_feet/5280
ttl = sprintf("Normalized Density with dt = %g sec, dx = %g ft", 
    dt_seconds, dx_feet)
s = list(firstcar = list(x = c(0, x2)))
maxflow = ffspeed * critical_density
fd = function(density, lanes) {
    if (any(density > lanes * jam_density)) {
        stop("Density is too large")
    }
    if (any(density < 0)) {
        stop("Density is too small")
    }
    congested = density > (lanes * critical_density)
    ifelse(congested, shock_speed * (density - lanes * jam_density), 
        ffspeed * density)
}
regions_per_quadrant = round(miles/(4 * dx))
s$firstcar$y = firstcar(s$firstcar$x)
slope2 = maxflow/(critical_density - 2 * jam_density)
supply = function(density, lanes) {
    congested = density > (lanes * critical_density)
    ifelse(congested, fd(density, lanes), lanes * maxflow)
}
demand = function(density, lanes) {
    congested = density > (lanes * critical_density)
    ifelse(congested, lanes * maxflow, fd(density, lanes))
}
n = 4 * regions_per_quadrant
density0 = rep(c(0.5, 0.5, 0.5, 0.5) * jam_density, each = regions_per_quadrant)
lanes = rep(c(1, 2, 2, 2), each = regions_per_quadrant)
shock2 = linefactory(slope2, x2, firstcar(x2))
iterate = function(density, lanes) {
    dm = demand(density, lanes)
    d = data.frame(supply = supply(density, lanes), demand = c(dm[n], 
        dm[seq(n - 1)]))
    d$inflow = apply(d, 1, min)
    d$outflow = c(d$inflow[2:n], d$inflow[1])
    density + (dt/dx) * (d$inflow - d$outflow)
}
y = dx * seq(0, n)
x3 = optimize(function(x) abs(shock2(x) - nojam(x)), interval = c(0.03, 
    0.05))$minimum
run = function(d0 = density0, ln = lanes) {
    out = matrix(NA, nrow = ntime, ncol = n)
    out[1, ] = d0
    for (t in seq(2, ntime)) {
        out[t, ] = iterate(out[t - 1, ], ln)
    }
    out
}
s$nojam = list(x = c(0, x3))
if (FALSE) {
    x = seq(0, jam_density, length.out = 20)
    plot(x, fd(x, lanes = 2))
    points(x, fd(x, lanes = 1), pch = 2)
    plot(x, supply(x, lanes = 2), ylim = c(0, 5000))
    points(x, supply(x, lanes = 1), pch = 2)
    plot(x, demand(x, lanes = 2), ylim = c(0, 5000))
    points(x, demand(x, lanes = 1), pch = 2)
    result = run()
    density01 = t(t(result)/(jam_density * lanes))
    {
        png("lwr.png", width = 1024, height = 1024)
        library(lattice)
        levelplot(density01[1:1200, ], aspect = "fill", ylab = "cell", 
            xlab = "time (iteration number)", main = "Density")
        dev.off()
    }
}
s$nojam$y = nojam(s$nojam$x)
result = run()
s$shock2 = list(x = c(x2, x3))
maxt = nrow(result)
s$shock2$y = shock2(s$shock2$x)
x = dt * seq(0, maxt)
density2 = t(t(result[1:maxt, ])/(jam_density * lanes))
s$standing = list(x = c(x3, 0.1), y = rep(nojam(x3), 2))
{
    pdf("uniform_start.pdf")
    image(x = x, y = y, z = density2, useRaster = TRUE, col = brewer.pal(9, 
        "Blues"), xlab = "Time (hours)", ylab = "Position (miles)", 
        xlim = range(x), main = "Starting with uniform density")
    dev.off()
}
{
    pdf(plotname)
    image(x = x, y = y, z = density2, useRaster = TRUE, col = brewer.pal(9, 
        "Blues"), xlab = "Time (hours)", ylab = "Position (miles)", 
        xlim = range(x), main = ttl, sub = "Orange lines are theoretical shockwaves")
    lapply(s, function(l) lines(l, lwd = 3, col = "orange"))
    text(0.003, 0.84, "Jam", col = "white", pos = 4)
    text(0.043, 0.84, "Congested", pos = 4)
    text(0.002, 0.6, "Empty", pos = 4)
    text(0.04, 0.25, "Lane Increase", pos = 4)
    text(0.03, 0.5, "Uncongested", pos = 4)
    text(0.0064, 0.38, "First Car", pos = 4)
    text(0.05, 0.62, "Standing Shock", pos = 2)
    text(0.016, 0.88, "Jam Dispersing", pos = 4)
    text(0.019, 0.69, "Secondary\nShock", pos = 1)
    dev.off()
}
