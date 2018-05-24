x = rnorm(1e5)
y = rnorm(1e5)
var_xy = cov(x, y)
vy = var(y)
vx = var(x)
# I think the greedy scheduling algorithm will do poorly on this script
# depending on the order the statements appear.
cor_xy = var_xy / sqrt(vy * vx)
cat(cor_xy, "\n")
