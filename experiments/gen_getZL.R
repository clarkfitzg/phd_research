#!/usr/bin/env Rscript

# 2018-05-30 06:51:07
# Automatically generated from R by autoparallel version 0.0.1

library(parallel)

nworkers = 2
timeout = 600

cls = makeCluster(nworkers, "PSOCK")

# Each worker updates a copy of this object. On worker j workers[[i]] will
# contain an open socket connection between workers j and i.
workers = vector(nworkers, mode = "list")

close.NULL = function(...) NULL


#' Connect workers as peers
connect = function(server, client, port, sleep = 0.1, ...)
{
    if(ID == server){
        con = socketConnection(port = port, server = TRUE
                , blocking = TRUE, open = "a+b", ...)
        workers[[client]] <<- con
    }
    if(ID == client){
        Sys.sleep(sleep)
        con = socketConnection(port = port, server = FALSE
                , blocking = TRUE, open = "a+b", ...)
        workers[[server]] <<- con
    }
    NULL
}


clusterExport(cls, c("workers", "connect", "close.NULL"))

# Each worker has an ID
clusterMap(cls, assign, "ID", seq(nworkers)
        , MoreArgs = list(envir = .GlobalEnv))

# Define the peer to peer connections
socket_map = read.csv(text = '
"server","client","port"
1,2,33000
')

# Open the connections
by(socket_map, seq(nrow(socket_map)), function(x){
    clusterCall(cls, connect, x$server, x$client, x$port, timeout = timeout)
})

worker_code = c(
'if(ID != 1)
    stop(sprintf("Worker is attempting to execute wrong code.
This code is for 1, but manager assigned ID %s", ID))

d = 100
N0 = 200
b = 4.605
d <- unserialize(workers[[2]])
y0 = matrix(rnorm(d * N0), N0, d)
serialize(y0, workers[[2]], xdr = FALSE)
n = N0 + 1
serialize(n, workers[[2]], xdr = FALSE)
k = 1
L <- unserialize(workers[[2]])
A = matrix(0, L, k)
serialize(k, workers[[2]], xdr = FALSE)
serialize(A, workers[[2]], xdr = FALSE)
count = 0
serialize(count, workers[[2]], xdr = FALSE)
serialize(k, workers[[2]], xdr = FALSE)
serialize(k, workers[[2]], xdr = FALSE)
serialize(k, workers[[2]], xdr = FALSE)
serialize(k, workers[[2]], xdr = FALSE)
serialize(k, workers[[2]], xdr = FALSE)
serialize(k, workers[[2]], xdr = FALSE)', 

############################################################

'if(ID != 2)
    stop(sprintf("Worker is attempting to execute wrong code.
This code is for 2, but manager assigned ID %s", ID))

k = 5
d = 100
L = 200
m = 1000
serialize(d, workers[[1]], xdr = FALSE)
y1 = matrix(rnorm(d * m), m, d)
y0 <- unserialize(workers[[1]])
y = rbind(y0, y1)
y.dist = as.matrix(dist(y))
diag(y.dist) = max(y.dist) + 100
n <- unserialize(workers[[1]])
distM = y.dist[(n - L + 1):n, (n - L + 1):n]
L = dim(distM)[1]
serialize(L, workers[[1]], xdr = FALSE)
k <- unserialize(workers[[1]])
A <- unserialize(workers[[1]])
for (i in 1:L) {
    A[i, ] = (sort(distM[i, 1:L], index.return = T)$ix)[1:k]
}
temp = table(A)
id = as.numeric(row.names(temp))
deg = rep(0, L)
deg[id] = temp
deg.sumsq = sum(deg^2)
count <- unserialize(workers[[1]])
for (i in 1:L) {
    ids = A[i, ]
    count = count + length(which(A[ids, ] == i))
}
k <- unserialize(workers[[1]])
vn = count/L/k
ts = 1:(L - 1)
q = (L - ts - 1)/(L - 2)
p = (ts - 1)/(L - 2)
k <- unserialize(workers[[1]])
EX1L = 2 * k * (ts) * (ts - 1)/(L - 1)
k <- unserialize(workers[[1]])
EX2L = 2 * k * (L - ts) * (L - ts - 1)/(L - 1)
k <- unserialize(workers[[1]])
config1 = (2 * k * L + 2 * k * L * vn)
k <- unserialize(workers[[1]])
config2 = (3 * k^2 * L + deg.sumsq - 2 * k * L - 2 * k * L * vn)
k <- unserialize(workers[[1]])
config3 = (4 * L^2 * k^2 + 4 * k * L + 4 * k * L * vn - 12 * k^2 * L - 4 * deg.sumsq)
f11 = 2 * (ts) * (ts - 1)/L/(L - 1)
f21 = 4 * (ts) * (ts - 1) * (ts - 2)/L/(L - 1)/(L - 2)
f31 = (ts) * (ts - 1) * (ts - 2) * (ts - 3)/L/(L - 1)/(L - 2)/(L - 3)
f12 = 2 * (L - ts) * (L - ts - 1)/L/(L - 1)
f22 = 4 * (L - ts) * (L - ts - 1) * (L - ts - 2)/L/(L - 1)/(L - 2)
f32 = (L - ts) * (L - ts - 1) * (L - ts - 2) * (L - ts - 3)/L/(L - 1)/(L - 2)/(L - 3)
var1 = config1 * f11 + config2 * f21 + config3 * f31 - EX1L^2
var2 = config1 * f12 + config2 * f22 + config3 * f32 - EX2L^2
v12 = config3 * ((ts) * (ts - 1) * (L - ts) * (L - ts - 1))/(L * (L - 1) * (L - 2) * (L - 3)) - EX1L * EX2L
X = X1 = X2 = rep(0, L - 1)
for (t in 1:(L - 1)) {
    X2[t] = 2 * (length(which(A[(t + 1):L, ] > t)))
    X1[t] = 2 * (length(which(A[1:t, ] <= t)))
    X[t] = 2 * (length(which(A[1:t, ] > t)) + length(which(A[(t + 1):L, ] <= t)))
}
Rw = q * X1 + p * X2
ERw = q * EX1L + p * EX2L
varRw = q^2 * var1 + p^2 * var2 + 2 * p * q * v12
Zw = (Rw - ERw)/sqrt(varRw)
Zdiff = ((X1 - X2) - (EX1L - EX2L))/sqrt(var1 + var2 - 2 * v12)
S = Zw^2 + Zdiff^2
M = apply(cbind(abs(Zdiff), Zw), 1, max)
out = list(R = X, R1 = X1, R2 = X2, Rw = Rw, Z1 = (X1 - EX1L)/sqrt(var1), Z2 = (X2 - EX2L)/sqrt(var2), Zdiff = Zdiff, Zw = Zw, S = S, M = M)'
)

evalg = function(codestring)
{
    code = parse(text = codestring)
    eval(code, .GlobalEnv)
    NULL
}

# Action!
parLapply(cls, worker_code, evalg)

# Close peer to peer connections
clusterEvalQ(cls, lapply(workers, close))

stopCluster(cls)
