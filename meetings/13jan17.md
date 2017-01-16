Mon Jan 16 09:49:10 PST 2017

Most of the meeting focused on parallel computing and memory management. A broad goal is to
have a more intelligent system that can detect and use parallelism in user's code.

R's memory semantics are copy on write. It would be interesting to see how
code analysis tools such as the `CodeDepends` and `CodeAnalysis` packages
could be used to avoid unnecessary memory copies.

A simple example of avoiding unnecessary memory copies:
Suppose `f(df)` is a function taking in a data frame with `n` rows and returning a
scalar. Consider performing `B` bootstrap replications of this:
```
for (b in 1:B)
    dfb = df[sample(1:n, replace=TRUE), ]
    fb = f(dfb)
    ... # (dfb never used again)
```
Each time we create a new data frame in memory with `n` rows. But for each
processor we really only need to request and allocate this space one time,
since subsequent iterations can write into the same memory.

Caveat: This just avoids the expense of garbage collection, so it may not
be worth it. 

### For next meeting:

- Present and critique Henrik's `futures` package / paper
- Can it be improved by static analysis? In what cases?
- Read Duncan's StatSci paper again and think of parallel extensions
- How do we detect when variables are modified? What are the cases?
- Come up with examples of making sequential parallel. Problems that are
  not embarrassingly parallel would be especially interesting.
