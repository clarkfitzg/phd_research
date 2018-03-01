Thu Mar  1 08:26:32 PST 2018

Nick and I spoke yesterday about his idea of converting code from the AST
into a "flat" data structure. I'll use an example to illustrate what I
mean.

Original code with tree structured AST produced by R's parsing:

```{R}
pryr::ast(means <- lapply(list(1:5, 2, rnorm(3)), mean))

\- ()
  \- `<-
  \- `means
  \- ()
    \- `lapply
    \- ()
      \- `list
      \- ()
        \- `:
        \-  1
        \-  5
      \-  2
      \- ()
        \- `rnorm
        \-  3
    \- `mean
```

Flattened code:

```{R}
.line1 = `:`(1, 5)
.line2 = rnorm(3)
.line3 = list(.line1, 2, .line2)
means = lapply(.line3, mean)
```

So flattening means that (every?) statement is a function call with only
literals or symbols for arguments. The dot prefix denotes a placeholder
variable, and also indicates that the object is a promise, which means that
it has different semantics.  We can represent it in a data frame as
follows:

```{R}
flat = data.frame(var = c(".line1", ".line2", ".line3", "means"))
flat$code = as.list(parse(text = "
    `:`(1, 5)
    rnorm(3)
    list(.line1, 2, .line2)
    lapply(.line3, mean)
"))
flat$goto = c(2, 3, 4, Inf)

flat

#      var                    code goto
# 1 .line1                     1:5    2
# 2 .line2                rnorm(3)    3
# 3 .line3 list(.line1, 2, .line2)    4
# 4  means    lapply(.line3, mean)  Inf
```

The `Inf` just denotes the end of the program.

Potential advantages of this approach:

- Easier to keep a corresponding data structure that holds other information
  related to the code that we would like to track, for example output
  dimensions or timing information.
- Flattened structure removes control flow, so there are fewer special
  cases to handle.
- Finer control if we allow eager evaluation of promises.

Talking it through with Nick we realized that to capture the task
parallelism that comes from the use-definition chain we need an actual
graph structure, possibly in addition to the flat data structure. If we
need this graph anyways then we potentially run into the same problems that come
from maintaining two corresponding data structures. 

The graph can probably be computed from the flat data structure, but then
we'll want to permute it.

Question for Nick- how do we flatten code that include control flow?
Ie. what does the resulting data frame look like?

```{R}
# Compute n!
n = 3
ans = 1
for(i in 1:n){
    ans = ans * i
}
```
