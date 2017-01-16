## Mon Jan 16 11:08:10 PST 2017

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

## Syntax

Defines a new operator `%<-%` for asynchronous assignment.

## Good Points

- Requires consistent behavior across different evaluation strategies.
