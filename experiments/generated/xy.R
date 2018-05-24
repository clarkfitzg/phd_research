nx = 1e5
ny = nx

x = data.frame(joinkey = sample.int(nx), value_x = rnorm(nx))
y = data.frame(joinkey = sample.int(nx, size = ny, replace = TRUE), value_y = rnorm(ny))

write.csv(x, "x.csv", row.names = FALSE)
write.csv(y, "y.csv", row.names = FALSE)
