loops = list(


list(loop = quote(
for(i in seq_along(x)) {
    ans[[i]] = f(x[[i]])
})
, parallel = TRUE
, info = "rewrote lapply"
)

, list(loop = quote(
for(i in x) {
   f(i)
})
, parallel = TRUE
, info = "Loop is pointless unless f is not a pure function. If it's not pure then we need to decide if it can be parallelized."
)

, list(loop = quote(
for(i in seq(along = x)){
   f(x[i])
}), parallel = TRUE
, info = "Similar, f() must have a side effect."
)

, list(loop = quote(
for(i in x) {
    ans = f(i)
})
, parallel = TRUE
, info = "loop is pointless, but order of execution matters"
)

, list(loop = quote(
for(i in x) {
    ii = i %% k
    ans[ii] = f(i)
})
, parallel = FALSE
, info = "assigns to computed index, so order of execution matters"
)

, list(loop = quote(
for(i in seq_along(x)) {
    x[[i]] = f(x[[i]])
})
, parallel = TRUE
, info = "Each iteration updates in place. May be a reasonable approach if x is huge."
)

, list(loop = quote(
for(i in x) {
    tmp1 = f1(i)
    tmp2 = f2(i)
    ans[i] = g(tmp1, tmp2)
})
, parallel = TRUE
, info = "Uses temporary variables."
)


, list(loop = quote(
for(i in 1:p){
    for(j in i:p){
        yij = X[i, j] * d[i] * d[j]
        Y[i, j] = yij
        Y[j, i] = yij
    }
})
, parallel = TRUE
, info = "Nested loop updating symmetric matrix. Hard."
)


, list(loop = quote(
for(i in 1:n) {
   estimate = estimate - alpha * gradient(estimate)
})
, parallel = FALSE
, info = "Iterative gradient descent"
)


, list(loop = quote(
for(i in x) {
    ii = i %% k
    ans[ii] = f(ii)
})
, parallel = TRUE
, info = "Updates based on a computed index. Weird and hard."
)

, list(loop = quote(
for(i in seq(along = x)){
   f(x[i], y[i])   
})
, parallel = TRUE
, info = "like mapply, f() should have side effects."
)

, list(loop = quote(
for(i in seq(along = x)[-1]) {
   j = i-1
   f(x[i], y[j])   
})
, parallel = TRUE
, info = "mapply offset by one, f() with side effects."
)

, list(loop = quote(
for(i in seq(along = x)[-1]) {
   j = i-1
   ans[i] = f(x[i], y[j])   
})
, parallel = TRUE
, info = "An 'offset' mapply that saves the result"
)

, list(loop = quote(
for(i in seq(along = x)[-1]) {
   j = i-1
   ans[i] = f(x[i], y[j], ans[j])   
}
)
, parallel = FALSE
, info = "read after write because of ans[i] = f(..., ans[i-1]), true dependence."
)



# Close big list
)
