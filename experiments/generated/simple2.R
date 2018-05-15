x = read.csv('x.csv')   # B
y = read.csv('y.csv')   # C
xy = merge(x, y)  # D
write.csv(xy, 'xy.csv', row.names = FALSE) # E
