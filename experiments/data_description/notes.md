These are notes as I develop a simple initial implementation of a data description.

Start assuming each chunk is a file on disk, and they fit into memory.

We need to know:
1. Where the chunks of data are on disk.
2. How to generate code to read them in.

The simplest possible thing is if the chunks are RDS files.

## Program

Suppose the program is just:

```{r}
xbar = mean(x)
```

This supports an object oriented approach, meaning that `x` has some class, say `ChunkedData` and `mean` is a method on that class.
We'd like to go beyond this to motivate more general code analysis and transformations.

```{r}
xbar = mean(x)
xcentered = x - xbar
```


