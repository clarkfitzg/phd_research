datadir = '~/data/'                      # A
x = read.csv(paste0(datadir, 'x.csv'))   # B
y = read.csv(paste0(datadir, 'y.csv'))   # C
xy = merge(x, y)                         # D
write.csv(xy, paste0(datadir, 'xy.csv')) # E
