Wed Dec 13 09:36:56 PST 2017

# Status

I'm reflecting now on the research progress so far, and on the future.

Duncan always asks: what are the new research ideas? As I look at what I've
done over the past year it seems like a bunch of relatively small things.
They can give incremental improvements in a few specific cases. All the
ideas relate to parallelism, but I'm nowhere near the stated goal of
a general program transformation system.

## Done

I've listed the more or less working ideas here with the most significant
first. 

The functions referenced below can be found in the `autoparallel`
package.

__R in Hive__ `write_udaf_scripts` provides a massive speedup
with much less code complexity for two particular classes of problems with
large data:

- Applying a vectorized R function (one output for each row)
- Reduction based on grouping by one column (one output for each group)

This uses standard interfaces to allow R to process streaming data.  It
mainly integrates existing technology in a useful way that's compatible
with R's computational model. This doesn't analyze code, but it does
generate code. The PEMS analysis demonstrates the practical value of this.

__Evolving Functions__ Let `f1(x)` and `f2(x)` be two different
implementations for the same function. For example, one may be a parallel
version that we generate based on the serial version. Usually the serial
version will outperform the parallel version when the data is small. We can
automatically and dynamically choose the faster implementation based on
properties of the argument `x`, while also updating the models that estimate
the required run time. For more details refer to
`autoparallel/inst/beta/evolve.Rmd`.

__Task Parallelism__ I've built some of the infrastructure and analysis
here based on CodeDepends, but I haven't come across any compelling use
cases to motivate an implementation with code generation of
`mcparallel` and `mccollect`. I've written this up in
`phd_research/expression_graph` and implemented parts in
`autoparallel/inst/beta/codegraph`.

__Column Use Inference__ `read_faster` analyzes code to
find the set of columns that are used and transforms the code to a version
that only reads and operates on this set of columns.

__Basic Parallelism__ `parallelize` efficiently distributes a single large
object `x` and executes code in parallel on it based on the presence of `x`
in the code. `benchmark_transform` simply replaces `lapply` with
`parallel::mclapply` if benchmarks indicate it's faster based on a t test.

## Difficulties

__Basic Parallelism__ It can be difficult, unnatural, and error prone to
transform R code into a version that can run in parallel. The parallel
versions are often slower.

I feel like R's C implementation puts a ceiling on the opportunities for
metaprogramming / code analysis / compilation in R. The current state of
the art is to write it in C or Rcpp to get speed. R's C code is hard to
read and analyze programmatically because of all the macros. Rcpp provides
an interface that's friendlier to programmers, but even more difficult for
analysis because it does its own code generation.

Writing more C / Rcpp code ties us more tightly to R's current model and
implementation. In 2008 Duncan and Ross Ihaka suggested replacing R
completely. Ross seems to still be following this path while Duncan thinks
the future lies in compiling R.

__Compiling R__ Duncan tries to push me towards this, but I keep balking.
Why?

- Julia and Python's numba already do it pretty well.
- It's hard. Ihaka describes R as [hostile to
  compilation](https://www.stat.auckland.ac.nz/~ihaka/downloads/New-System.pdf)
- I don't see the resources or motivation in the R community to take it
  beyond an experiment into a truly viable solution

__C/C++ generation__ This is something I've played a little with but found
difficult to really get the hang of. It doesn't help that I have only a
basic understanding of C.

## Next Steps

__DAG__ 

__Julia__ I've considered moving my work to Julia before- why didn't I do
it?

- Duncan and Nick work in R.
- It will take time for me to develop expertise.
- Not much statistical functionality built out yet.
- The language has been unstable, ie. names and functionality changing.
  This seems to be less of an issue as they move to version 1.0.
- No standard solution for missing data such as R's `NA`. But now
  the master branch has `missing`.
- Mixed experiences interacting with Julia developers.
- In a 2015 talk creator Jeff Bezanson didn't seem to think vectorization
  was important. But it's still there in the language, and doesn't seem to
  be going anywhere.


## Miscellaneous notes

Rather than writing a compiler, "_you should learn how to enhance whatever
existing language you have with one or more preprocessors_" - Software
Tools by Kernighan and Plauger.

There's very little multicore in R's C code. In 2010 Luke Tierney added
OpenMP to `colsums` in base R. `data.table` does all kinds of things in C
code to get speed, and it's quite fast.
