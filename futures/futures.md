## Mon Jan 16 11:08:10 PST 2017

```

library("future")

```

## Syntax

Defines a new operator `%<-%` for asynchronous assignment.

## Evaluation Strategies

__lazy__ starts resolving when needed.
__eager__ starts resolving immediately.

Ran synchronously this code behaves just like vanilla R, pausing before
returning the prompt:
```

slow1 = function(sleep = 5)
{
    cat("starting slow1!\n")
    Sys.sleep(sleep)
    1
}

a %<-% slow1()

```

Evaluation of expressions happen in a local environment that's fixed when
the future is created, as in a function, so it can't modify global state.

```

a <- 10

b <- future({a <- 0; a + 1})

# Expect a = 10, b = 1
> a
[1] 10
> value(b)
[1] 1

```

What kind of object is `a` before it's used? Presumably an 
unevaluated future. `futureOf()` extracts the actual object.

```

plan("lazy")
a %<-% {Sys.sleep(1); cat("OK!"); 10}
fa = futureOf(a)

> fa
LazyFuture:
Label: ‘<none>’
Expression:
{
    cat("OK!")
    10
}
Lazy evaluation: TRUE
Asynchronous evaluation: FALSE
Local evaluation: TRUE
Environment: <environment: 0x2ca2d38>
Globals: <none>
L'Ecuyer-CMRG RNG seed: <none>
Resolved: FALSE
Value: <not collected>
Early signalling: FALSE
Owner process: c33c47c0-c06d-a2f1-6812-6c852d9d7b8f
Class: ‘LazyFuture’, ‘UniprocessFuture’, ‘Future’, ‘environment’

> class(a)
OK![1] "numeric"
> a
[1] 10

```


## Globals

Uses [globals package](https://github.com/HenrikBengtsson/globals) which
builds on the `codetools` package to identify and handle global variables.

> identifying globals from static code inspection alone is a challenging
> problem.

Globals need to be identified so that they can be exported to the processes
that are evaluating them. If they are small and there are few of them, it's
no problem to send them over. If they're huge then it can be a problem.

Different strategies can be selected:
"Conservative" tries to find __only__ those that it's sure are globals.
"Liberal" tries to find __all__ the globals, and may identify variables
that are not actually globals.

How does it do it? By walking through all the expressions via
`codetools::walkCode`.

From the documentation for `globals::globalsOf`:

```
Examples:

     b <- 2
     expr <- substitute({ a <- b; b <- 1 })

     ## Will _not_ identify 'b' (because it's also a local)
     globalsC <- globalsOf(expr, method="conservative")
     print(globalsC)

     ## Will identify 'b'
     globalsL <- globalsOf(expr, method="liberal")
     print(globalsL)
```

## Good Points

Requires consistent behavior across different evaluation strategies,
including synchronous eager, synchronous lazy, asynchronous
multiprocessing, and asynchronous cluster.

Mechanisms limit nesting of futures so that one doesn't inadvertantly spawn
too many processes. Also provides a [way to override
this](https://cran.r-project.org/web/packages/future/vignettes/future-3-topologies.html).

`backtrace(f)` provides a way to debug futures that fail.

Supporting packages `globals` and `listenv` are generally useful, and so
have been made into their own packages. A nice way to organize code and
separate out functionality.

`demo("mandelbrot", package="future", ask=FALSE)` provides a compelling
visual demo.

## Critiques

There are a few technical gotchas that are well described in a
[vignette](https://cran.r-project.org/web/packages/future/vignettes/future-2-issues.html).

Broader thought: OpenCL describes two common styles of parallelism.
__Task__ parallelism is when each task is independent, so they can
therefore happen in parallel. __Data__ parallelism is when the same
function can be applied in parallel to every element of a data structure.
The `future` package is very much task parallelism, while the parallel
constructs that I'm familiar with in R like the `parallel::apply` type
functions are data based. Are there cases when it is beneficial to combine
the two? Certainly:

```
a %<-% sapply(bigX, slowFUN)
b <- mean(a)
```

Right now it's not clear how to combine these two strategies with `future`.

Current implementation blocks when all the workers are busy. The
alternative is to manage a queue. Henrik has already thought of this:

> The only work around for this is to have an internal queue of futures
> that will be resolved as resources gets available. However, going down
> that path is major work and basically risks reinventing job schedulers
> and / or BatchJobs.

Asynchronous techniques are useful for programming on networks, because
each call is inexpensive, yet it takes a relatively long time for a
response over the network. It's not clear that `future` would help
tremendously for this application.

Consider the following code:

```

slow_add = function(x, sleep = 2)
{
    Sys.sleep(sleep)
    x + 1
}

# In theory, the first 2 blocks of code can execute at the same time.

a1 %<-% slow_add(1)
b1 %<-% slow_add(a1)
c1 %<-% slow_add(b1)

a2 %<-% slow_add(1)
b2 %<-% slow_add(a2)
c2 %<-% slow_add(b2)

sapply(c(c1, c2), slow_add)

```

With 2 slave processes this can potentially run in 3 * sleep time = 6 seconds.
But because of the above reason it doesn't- it's blocked after the second
line as b1 is evaluated by a different process. Similar to pipelining idea
in Spark.

## Further Thoughts

Static analysis opens up some new possibilities. For example, running code
out of order or detecting parallel patterns and executing in parallel.

It might be possible to detect errors around argument classes. But this
would break R's lazy evaluation semantics and really only makes sense for
S4 methods.

```

> a %<-% sum("this will fail")
> a + 10
Error: invalid 'type' (character) of argument

```


What if you know how long each computation will take? This is theoretically
impossible, and practically it's hard to know with stochastic, iterative
computations. But it may be possible to know approximately how long each
line of code takes to run.  This adds something to the computational task
graph. Then it may be possible to take the static analysis and transform it
into a mathematical optimization problem.

Would lines of code be a good unit? Maybe not,
since these should collapse into the same things:
```

b = f1(a)
b = f2(b)
b = f3(b)

OR

b = f3(f2(f1(a)))
```



## Don't Understand

The `%plan%` operator is included to temporarily change the plan strategy
and recommended only for interactive prototyping. This seems unnecessary.

```

> plan("eager")
> a %<-% {cat("OK!"); 10} %plan% lazy
> a
OK![1] 10

```

## Experiments

```

plan("eager")

plan("multiprocess")

a %<-% {cat("start\n")
    Sys.sleep(10)
    cat("end\n")
    10
} %lazy% FALSE

b %<-% {cat("hey\n"); 10} %lazy% TRUE

```

## Experiments
