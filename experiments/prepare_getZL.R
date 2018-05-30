d = 100
k = 5
d = 100
N0 =200
L =200
b = 4.605 #35

m =1000

y0 = matrix(rnorm(d*N0),N0,d)
y1 = matrix(rnorm(d*m),m,d)
y = rbind(y0,y1)
y.dist = as.matrix(dist(y))
diag(y.dist) = max(y.dist)+100
n = N0+1
distM = y.dist[(n-L+1):n,(n-L+1):n]
k = 1
