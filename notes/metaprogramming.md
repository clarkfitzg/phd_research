# Metaprogramming in R

Notes as I learn _programming on the language_.

The definitive reference is the [R language
reference](https://cran.r-project.org/doc/manuals/r-release/R-lang.html).

## Creating language objects

```{R}

a = quote(x <- 1:10)

> a
x <- 1:10
> class(a)
[1] "<-"

# Multiline using {
a2 = quote({
    x <- 1:10
    mean(x)
})

```

`quote` returns the expression that was passed in. `parse` will parse a
string into an expression object which can be manipulated like a list.

```{R}

p = parse(text = "
    x <- 1:10
    mean(x)
")

> p[[1]]
x <- 1:10

```

TODO: Are there pros and cons to using one or the other? If I use quote and
`{` then this requires removing the `{`. But strings somehow seem
inelegant. Alternatively I can pass it in as an expression:

```{R}

e = expression(
    x <- 1:10,
    mean(x)
)

```

statements are "one line" in an R script, while expressions may contain
multiple statements. Expressions act like lists. My general thought is to
write most functions to operate on the statements, since they are 
simpler. 

## `call` objects

```{R}
incode = quote(apply(x, 2, max))

> incode
apply(x, 2, max)
```

`incode` is an object of class `"call"`. It represents a call to the
`apply()` function. Given an appropriate `x` then `incode` can be
evaluated with `eval`.

```{R}
> x = matrix(1:10, ncol = 2)
# The max along each column
> eval(incode)
[1]  5 10
```

```{R}
> incode[1]
apply()
> incode[3]
2()
> class(incode[3])
[1] "call"
> incode[[3]]
[1] 2
```

Indexing with single brackets `[` preserves the class `call`, but it
doesn't make much sense in this context. Duncan claims that people rarely
bother to manipulate these code objects, so it's not something that the R
developers worry much about. In this case we need to index into the
underlying object using `[[`.

## Testing for Equality

Use `identical`.

```{R}
> a = `<-`
> identical(a, `<-`)
[1] TRUE
```
