These are notes as I develop a simple initial implementation of a data description.

Start assuming each chunk is a file on disk, and they fit into memory.

We need to know:
1. Where the chunks of data are on disk.
2. How to generate code to read them in.

The simplest possible thing is if the chunks are RDS files.

## Program

Suppose the program is just:

```{r}
xmin = min(x)
```

This supports an object oriented approach, meaning that `x` has some class, say `ChunkedData` and `min` is a method on that class.
We'd like to go beyond this to motivate more general code analysis and transformations.

Thinking now of a totally different way to implement it.
What if we did use the object oriented approach?
We just defer everything until the user asks for something, say `compute(xmin)`.
This is essentially how dask works.
When we evaluate the code we just build the graph.
Maybe the distinction between this and analyzing the entire block of code doesn't matter all that much, since it's largely just a matter of implementation.

Returning to the data description.
What are the minimal things I need to run this code in parallel?
What would the code in R look like?

```{r}
xd = list(files = c("x1.rds", "x2.rds")
    , file_load_fun = readRDS
)
```

We also need to know how to reduce `min`.

```{r}
reduce_funcs = list(
    min = list(summarize_chunk = min
            , list_combiner = function(l) do.call(min, l))
)
```

Then we can generate this code:

```{r}
process_file = function(filename)
{
    chunk = xd[["file_load_fun"]](filename)
    reduce_funcs[["min"]][["summarize_chunk"]](chunk)
}

tmp = lapply(xd[["files"]], process_file)

xmin = reduce_funcs[["min"]][["list_combiner"]](tmp)
```

If I substitute the actual values it becomes more readable:

```{r}
process_file = function(filename)
{
    chunk = readRDS(filename)
    min(chunk)
}

tmp = lapply(c("x1.rds", "x2.rds"), process_file)

xmin = do.call(min, tmp)
```

-------

Ideally, this should not be specific to R.
That is, I should be able to generate this `x_desc` object from a programming language agnostic data description.
The rds files are of course R specific, but this is just a starting step.
It could just as easily be:

```{r}
x_desc = list(files = c("x1.csv", "x2.csv")
    , file_load_fun = read.csv
)
```

-------

Generalizing to different data sources, say a database, it might look something more like this:

```{r}
xd = list(setup = NULL
    , chunk_load_fun = list(fun = readRDS, parallel = TRUE)
    , chunk_load_args = c("x1.rds", "x2.rds")
    , combine_fun = c
)
```

- `setup` is code to run before anything else.
- `chunk_load_fun` contains a function that will load chunks, and a flag `parallel` that says whether we can load these chunks in parallel.
- `chunk_load_args` is a list such that calling `chunk_load` on the `i`th element loads the `i`the chunk.
- `combine_fun` is a function to assemble the list of chunks together into a single object in one R process.
    This is useful when we have to call a general function on the whole object.
