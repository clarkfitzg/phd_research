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

One way to flatten code:

```{R}
.line1 = `:`(1, 5)
.line2 = rnorm(3)
.line3 = list(.line1, 2, .line2)
means = lapply(.line3, mean)
```

So flattening means that (every?) statement is a function call (maybe the
`identity()` function)with only
literals or symbols for arguments. The dot prefix denotes a placeholder
variable. We can represent it in a data frame as
follows:

```{R}

flat = data.frame(var = c(".line1", ".line2", ".line3", "means")
    , promise = c(TRUE, TRUE, TRUE, FALSE))
flat$code = as.list(parse(text = "
    `:`(1, 5)
    rnorm(3)
    list(.line1, 2, .line2)
    lapply(.line3, mean)
"))
flat$goto = c(2, 3, 4, Inf)

flat

     var promise                    code goto
1 .line1    TRUE                     1:5    2
2 .line2    TRUE                rnorm(3)    3
3 .line3    TRUE list(.line1, 2, .line2)    4
4  means   FALSE    lapply(.line3, mean)  Inf
```

The `Inf` just denotes the end of the program.

Potential advantages of this approach:

- We can add any columns to this data frame that we like, for example
  dimensions of arguments or timing information.
- Flattened structure hides control flow, so there are fewer special
  cases to handle.
- Finer control if we allow eager evaluation of promises.

Talking it through with Nick we realized that to capture the task
parallelism that comes mostly from the use-definition chain we need an
actual graph structure, possibly in addition to the flat data structure. If
we need this graph anyways then we potentially run into the same problems
that come from maintaining two corresponding data structures. 

The graph can probably be computed from the flat data structure, but then
we'll want to permute it.

Question for Nick- how do we flatten code that includes control flow?
Ie. what does the resulting data frame look like? Here's an example:

```{R}

# Compute n!
n = 3
ans = 1L
for(i in 2:n){
    ans = ans * i
}
print(ans)

```

I can imagine something like this:

```{R}

flat = data.frame(var = c("n", "ans", ".iter_over", ".last", ".i_index",
"i", "ans", ".i_index", ".test_end_for", ".print"))
flat$code = as.list(parse(text = "
    identity(3)
    identity(1)
    2:n
    length(.iter_over)
    identity(1)            
    .iter_over[[.i_index]]
    ans * i
    .i_index + 1L
    .i_index > .last
    print(ans)
"))
flat$goto = c(2:10, Inf)
flat$if_false = rep(NA, nrow(flat))
flat$if_false[9] = 6

flat

#              var                   code goto if_false
# 1              n            identity(3)    2       NA
# 2            ans            identity(1)    3       NA
# 3     .iter_over                    2:n    4       NA
# 4          .last     length(.iter_over)    5       NA
# 5       .i_index            identity(1)    6       NA
# 6              i .iter_over[[.i_index]]    7       NA
# 7            ans                ans * i    8       NA
# 8       .i_index          .i_index + 1L    9       NA
# 9  .test_end_for       .i_index > .last   10        6
# 10        .print             print(ans)  Inf       NA

```

Line 9 tests for the end of the for loop. It is special because it is the
only statement that can GOTO two different places in the code. I'm not sure
if the two column approach here is the best way, but we need to allow for
it somehow.
