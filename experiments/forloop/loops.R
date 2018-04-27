loop1 = quote(
for(i in seq_along(x)) {
    ans[[i]] = f(x[[i]])
})
attr(loop1, "parallel") = TRUE
attr(loop1, "info") = "rewrote lapply"


loop2 = quote(
for(i in x) {
    ans = f(i)
})
attr(loop2, "parallel") = TRUE
attr(loop2, "info") = "loop is pointless, but order of execution matters"


loop3 = quote(
for(i in x) {
    ii = i %% k
    ans[ii] = f(i)
})
attr(loop3, "parallel") = FALSE
attr(loop3, "info") = "assigns to computed index, so order of execution matters"


loop4 = quote(
for(i in seq_along(x)) {
    x[[i]] = f(x[[i]])
})
attr(loop4, "parallel") = TRUE
attr(loop4, "info") = "Each iteration updates in place. May be a reasonable
    approach if x is huge."


loop5 = quote(
for(i in x) {
    tmp1 = f1(i)
    tmp2 = f2(i)
    ans[i] = g(tmp1, tmp2)
})
attr(loop5, "parallel") = TRUE
attr(loop5, "info") = "Uses temporary variables."


loop6 = quote(
for(i in 1:p){
    for(j in i:p){
        yij = X[i, j] * d[i] * d[j]
        Y[i, j] = yij
        Y[j, i] = yij
    }
})
attr(loop6, "parallel") = TRUE
attr(loop6, "info") = "Nested loop updating symmetric matrix. Hard."


loop7 = quote(
for(i in 1:n) {
   estimate = estimate - alpha * gradient(estimate)
})
attr(loop7, "parallel") = FALSE
attr(loop7, "info") = "Iterative gradient descent"


loop8 = quote(
for(i in x) {
    ii = i %% k
    ans[ii] = f(ii)
})
attr(loop8, "parallel") = TRUE
attr(loop8, "info") = "Updates based on a computed index. Weird and hard."
