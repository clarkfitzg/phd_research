y = read.csv('y.csv')   # C
x = read.csv('x.csv')   # B
xy = merge(x, y)  # D
write.csv(xy, 'xy.csv', row.names = FALSE) # E
