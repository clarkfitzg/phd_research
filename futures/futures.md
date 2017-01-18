## Mon Jan 16 11:08:10 PST 2017

Broader thought: OpenCL describes two common styles of parallelism.
__Task__ parallelism is when each task is independent, so they can
therefore happen in parallel. __Data__ parallelism is when the same
function can be applied in parallel to every element of a data structure.
The `future` package is very much task parallelism, while things like
`parallel::apply` type functions are data based. Are there cases when it
is beneficial to combine the two? Certainly:

```
a %<-% sapply(bigX, slowFUN)
b <- mean(a)
```

Right now it's not clear how to combine these two strategies with `future`.

```

library("future")

```

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

Evaluation of expressions happen locally, as in a function, so it can't
modify global state.

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


## Syntax

Defines a new operator `%<-%` for asynchronous assignment.

## Miscellaneous

Uses [globals package](https://github.com/HenrikBengtsson/globals) which
builds on the `codetools` package to identify and handle global variables.

> identifying globals from static code inspection alone is a challenging
> problem.

globals need to be identified so that they can be exported to the processes
that are evaluating them. If they are small and there are few of them, it's
no problem to send them over. If they're huge then it can be a problem.

## Good Points

Requires consistent behavior across different evaluation strategies,
including synchronous eager, synchronous lazy, asynchronous
multiprocessing, and asynchronous cluster.

Mechanisms limit nesting of futures so that one doesn't inadvertantly spawn
too many processes. Also provides a [way to override
this](https://cran.r-project.org/web/packages/future/vignettes/future-3-topologies.html).

`backtrace(f)` provides a way to debug futures that fail.

## Critiques

## Don't Understand

The `%plan%` operator is included to temporarily change the plan strategy
and recommended only for interactive prototyping. This seems unnecessary.

```

> plan("eager")
> a %<-% {cat("OK!"); 10} %plan% lazy
> a
OK![1] 10

```
