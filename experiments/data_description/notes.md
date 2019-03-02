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
    , chunk_load = list(fun = readRDS, parallel = TRUE, args = c("x1.rds", "x2.rds"))
    , combine_fun = c
)
```

- `setup` is code to run before anything else.
- `chunk_load` contains everything we need to load chunks:
    - `fun`, a function that will load chunks
    - `parallel`, a flag that says whether we can load these chunks in parallel
    - `args` is a list such that calling `chunk_load` on the `i`th element loads the `i`the chunk.
- `combine_fun` is a function to assemble the list of chunks together into a single object in one R process.
    This is useful when we have to call a general function on the whole object.

------------------------------------------------------------

It's not that difficult to write the code generator, given the code blocks that should happen in parallel.
What is the most difficult part?

What pieces need to come together to make this happen, and how difficult do I think each one will be?

Component   |   Difficulty  |   Description   
------------|---------------|-------------------------------
Code generator  |   Medium     |   Generate parallel code from vectorized blocks, many details
Infer vectorized blocks |   Medium - Hard | Group nodes in the makeParallel graph
Enumerate vectorized functions  |   Easy    | List out all the vectorized functions, and which parameters they are vectorized in.
Generate data description object  |   Medium    | Given a language agnostic data description, create the R objects above.

Inferring vectorized blocks still seems like the most unknown part.
I need to actually do it so that I can see what issues come up.
I have to know the vectorized functions before I can infer vectorized blocks, but I can start with an easy small subset.

I have ideas on how to implicitly identify the large data sources, but I'm missing a clear idea on how to save results.
What's the point of all the computations?
How does the user specify which objects to write out and save?
Here are a few options:

1. Code says what to save, where and how
1. `makeParallel` user specifies which variables to save
2. `makeParallel` attempts to do something reasonable, for example, save the last object

These aren't mutually exclusively. I could potentially do all of them.

The first option is appealing- it's how users must write their scripts anyways.
It's also common to produce data for something other than R, and users need full control over that.
What are the common ways to save data in base R? `write.table, save`
If the calls are simple, something like `write.table(result, 'result.txt')`, then I can analyze these calls and potentially run them within the chunks.
Then I could postprocess the files and combine them as necessary.

I can generate code from something like a `BlockDependGraph`, that groups all the vectorized functions into blocks.


------------------------------------------------------------

Thinking a little more about the data description.
It would be good to have some concept of indexing or partitioning.
Partitioning is probably the better word, because indexing is more a feature of a database.
For example, splitting the data files based on some variable value.
Examples: agency ID's in the usaspending data, station ID's in the PEMS.
I could also have generic ways to repartition the data on disk.

The computations may or may not use the partitioning, so I need to detect if the code uses it.
Code such as `tapply, by, split` can use it.
These seem pretty specific though.

Duncan did say that he wanted to do more with the data movement.
The more interesting case of data movement is with the data distributed as on a cluster.
At that point, I risk reinventing Hadoop.
Does anything really change from the single node case?
Suppose that each group of data is only on one node, and one node can have many groups.
An updating algorithm could be interesting here, and we would need the capabilities of MPI.
There is an RMPI package, so we could build on that.

How would we minimize cost of data movement?
There have to be multiple possibile computational plans.
With what I described above, the natural thing to do is compute on the data local to each node.
Which is only one possibility.

TODO: think about how to make more possibilities.
