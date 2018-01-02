# Status

I'm reflecting now on the research progress so far, and on the future.

Duncan always asks: what are the new research ideas? As I look at what I've
done over the past year it seems like a bunch of relatively small things.
They can give incremental improvements in a few specific cases. All the
ideas relate to parallelism, but I'm nowhere near the stated goal of
a general program transformation system.

## Done

I've listed the more or less working ideas here with the most significant
first.  The functions referenced below can be found in the `autoparallel`
package.

__R in Hive__ `write_udaf_scripts` provides a massive speedup
with much less code complexity for two particular classes of problems with
large data:

- Applying a vectorized R function (one output for each row)
- Reduction based on grouping by one column (one output for each group)

This uses standard interfaces to allow R to process streaming data.  It
mainly integrates existing technology in a useful way that's compatible
with R's computational model, so it isn't really "new". This doesn't
analyze code, but it does generate code. The PEMS analysis demonstrates the
practical value of this.



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
cases to motivate an actual implementation including code generation of
`mcparallel` and `mccollect`. I've written this up in
`phd_research/expression_graph` and implemented parts in
`autoparallel/inst/beta/codegraph`.

__Column Use Inference__ `read_faster` analyzes code to
find the set of columns that are used and transforms the code to a version
that only reads and operates on this set of columns.

__Basic Parallelism__ `parallelize` efficiently distributes a single large
object `x` and executes code in parallel based on the presence of the
symbol `x` in the code. `benchmark_transform` simply replaces `lapply` with
`parallel::mclapply` if benchmarks indicate it's faster based on a t test.

## Difficulties

__Basic Parallelism__ It can be difficult, unnatural, and error prone to
transform serial into parallel code. The parallel versions are often
slower. This holds for all languages that I've used, not just R.

__Analyzing R Code__ is sometimes difficult because often there are many
different ways in R to do the same thing. Bring in external packages /
other systems and it gets worse. Think about all the OO models, for example.

I feel like R's C implementation puts a ceiling on the opportunities for
metaprogramming / code analysis / compilation in R. The current state of
the art is to write it in C or Rcpp to get speed. R's C code is hard to
read and analyze programmatically because of all the macros. Rcpp provides
an interface that's friendlier to programmers, but even more difficult for
analysis because it generates its own code.

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

## Future work in R

The parallelism seems only capable of producing marginal gains. But there
are other things to do with R:

__R in databases__ The idea is to move code to the data and use R's
vectorized computational model even if the database isn't columnar. It's a
natural idea because R's data frame and a table in a relational database
are essentially the same thing. This could build off Duncan's work with
user defined R functions in SQLlite, and my work in Hive. Hannes Muehleisen
has done work here in MonetDB. I can potentially use the code analysis
here, finding efficient combinations of R and SQL code. For example, it's
likely more efficent to express all the simple row filters in SQL so that R
has less data to operate on.

I won't find as many use cases in academia, because academics are more
likely to analyze data in files than repeatedly run queries on a production
database.  This work may require me to learn more about C level interfaces
between databases and R.

__Improving R code__ Much of the slow R code that I've seen "in the wild"
is just badly written by researchers with no training in programming.
Problems include:

- Repeating code many times
- Lack of modularity
- Computing same quantity unnecessarily
- Non idiomatic, ie. globals in the wrong place

Rather than focusing on performance this is more about identifying and
possibly fixing problems found in users code. In that sense it's like a
linter. But it can be difficult, for example when someone rewrites R's
`table()` or `cov2cor()`. This is very hard to detect.

## Julia

I can continue with what I've been doing with R, finding ways to analyze
and transform code to marginally improve speed and scalability. Or I could
move this parallel analysis to a different language.

Duncan critiques software that reimplements the same idea. For example,
developers ported data frames from R to many languages. The Julia
stats community could certainly use more contributors, but Duncan wouldn't
like to see me reimplementing existing functionality. It would be
educational for me, but not research.

I've considered moving my work to Julia before. What appeals to me about
Julia?

- Designed for speed built off LLVM. Speed becomes more important with
  large data. 
- Modern design benefits from seeing seeing design choices in other
  languages
- No "two language" problem- therefore code analysis is potentially easier
  and can go farther.

What could I do in Julia that's qualitatively new? How does it go beyond R?

- Use the speed to extend analysis to larger data sets.
- Have an easier time running parallel stuff on the GPU, because more of
  the infrastructure is in place.
- It may be possible to tap into Julia's type inference data flow algorithms 
  to construct more efficient parallel programs based on data flow.

So why haven't I focused on Julia?

- Duncan and Nick work in R.
- Takes time for me to develop expertise.
- Lacks much of the statistical functionality that R has. Although
  [JuliaStats on Github](https://github.com/JuliaStats) seems to be very
  active.
- Instability, ie. names and functionality changing.
  This seems to be less of an issue as they move to version 1.0.
- No standard solution for missing data such as R's `NA`. But now
  the master branch has `missing`.
- Mixed experiences interacting with Julia developers.
- In a 2015 talk creator Jeff Bezanson didn't seem to think vectorization
  was important. But loop fusion [loop
fusion](https://julialang.org/blog/2017/01/moredots) of vectorize funcs
seems to work very well.

## Miscellaneous notes

Rather than writing a compiler, "_you should learn how to enhance whatever
existing language you have with one or more preprocessors_" - Software
Tools by Kernighan and Plauger.

There's very little multicore in R's C code. In 2010 Luke Tierney added
OpenMP to `colsums` in base R. `data.table` does all kinds of things in C
code to get speed, and it's quite fast.
