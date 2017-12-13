Wed Dec 13 09:36:56 PST 2017

# Status

I'm reflecting now on the research progress so far, and on the future.

## Working

The functions referenced below can be found in the `autoparallel` package.

__R in Hive__ `write_udaf_scripts` provides a massive speedup
with much less code complexity for two particular classes of problems with
large data:

- Applying a vectorized R function (one output for each row)
- Reduction based on grouping by one column (one output for each group)

This doesn't do any code analysis, but it does generate code.

__Column Use Inference__ `read_faster` analyzes code to
find the set of columns that are used and transforms the code to a version
that only reads and operates on this set of columns.

__Basic Parallelism__ `parallelize` efficiently distributes a single large
object `x` and executes code in parallel on it based on the presence of `x`
in the code. `benchmark_transform` simply replaces `lapply` with
`parallel::mclapply` if benchmarks indicate it's faster based on a t test.

## Difficult

__Basic Parallelism__ It's

__Task Parallelism__ I've built some of the infrastructure and analysis
here based on CodeDepends, but I haven't come across any compelling use
cases.

__Compiling R__ Duncan tries to push me towards this, but I keep balking.
Why?

- Julia and Python's numba already do it pretty well.
- I don't see the resources in the R community to take it beyond an
  experiment into something that people will actually use.
