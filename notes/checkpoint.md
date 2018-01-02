Wed Dec 13 09:36:56 PST 2017

# Status

I'm reflecting now on the research progress so far, and on the future.

Duncan always asks: what are the new research ideas? As I look at what I've
done over the past year it seems like a bunch of relatively small things.
They can give incremental improvements in a few specific cases. All the
ideas relate to parallelism, but I'm nowhere near the stated goal of
a general program transformation system.

## Done

> I've listed the more or less working ideas here with the most significant
> first.  The functions referenced below can be found in the `autoparallel`
> package.
> 
> __R in Hive__ `write_udaf_scripts` provides a massive speedup
> with much less code complexity for two particular classes of problems with
> large data:
> 
> - Applying a vectorized R function (one output for each row)
> - Reduction based on grouping by one column (one output for each group)
> 
> This uses standard interfaces to allow R to process streaming data.  It
> mainly integrates existing technology in a useful way that's compatible
> with R's computational model, so it isn't really "new". This doesn't
> analyze code, but it does generate code. The PEMS analysis demonstrates the
> practical value of this.

------------------------------------------------------------

### Summary

Combining [Apache Hive](https://Hive.apache.org/) with the 
[R language](https://www.r-project.org/) reduced the run time of a practical
data analysis script from a couple days to 12 minutes.

[Here's the
code.](https://github.com/clarkfitzg/phd_research/tree/master/analysis/pems/hadoop)

### Introduction

Researchers have worked with R and Hadoop for many years, i.e.  through
[Hadoop's streaming
interface](https://www.r-bloggers.com/integrating-r-with-apache-hadoop/) or
[RHIPE and deltarho](http://deltarho.org/). The approach with Hive
described here complements these efforts, while staying mostly higher
level.

__EDIT 27 Nov 17__ Today I stumbled across the [`RHive`
package](https://github.com/nexr/RHive) which was
[archived on CRAN](https://cran.r-project.org/src/contrib/Archive/RHive/).
I've briefly looked at the code, and the approach seems similar to what I
describe here. It works more interactively, running queries from within an
existing R session. The core of the processing uses a `for` loop in R to
process each line for the reduce step. In my experience this approach is
much slower than the vectorized approach described in this post, but I haven't
verified this for `RHive`.

Hive tables are also [accessible from R through
JDBC](http://jarrettmeyer.com/2016/11/03/Hive-and-r-playing-nicely-together).
One can use JDBC to load data from Hive directly into a local R session.
This approach is excellent for interactive and exploratory data analysis
with manageable data sets.  However, it won't work for processing a large
amount of data in Hive through R, because it brings the data to the code.
The network and the single local R session are a bottleneck.  For large
data sets it's much better to bring the code to the data, which is the
topic of this post.  We'll see how to run R _inside_ Hive, thus fully
utilizing the power of the cluster.

[Yesterday's post]({{ site.baseurl }}{% post_url
2017-10-30-hive-udaf-with-R %}) showed some of the basics of using Hive
with R, along with debugging.  This post shows a more realistic use case
processing 3 billion rows of traffic sensor data.
Hive does the column selection and the group by; R performs the
calculation. Each group fits easily in worker memory, so each Hive worker
can apply an R script to the data, one group at a time. This technique
plays off the strengths of each system.  Hive handles storage, column
selection, basic filtering, sorting, fault tolerance, and parallelism. R
lets us express arbitrary analytic operations through R functions.

### SQL

This Hive SQL query applies the transformation:

```{sql}
INSERT OVERWRITE TABLE fundamental_diagram
SELECT
TRANSFORM (station, flow2, occupancy2)
USING "Rscript piecewise_fd.R"
-- The names of all the variables that are produced
AS(station 
  , n_total 
  , n_middle 
  , n_high 
  )
FROM (
    SELECT station, flow2, occupancy2
    FROM pems 
    CLUSTER BY station
) AS tmp
;
```

Hive does the following:
1. Selects three columns from the table `pems`. Selecting just the
   necessary columns for the transform reduces overhead.
2. Groups the selected columns so that the unique values of the `station`
   columns are streamed through the transform in consecutive order. The critical `CLUSTER
   BY station` statement guarantees this.
3. Sends the now grouped output of the three columns as `stdin` to be
   processed by the command `Rscript piecewise_fd.R`.
4. Reads the results from `stdout`, overwriting the table
   `fundamental_diagram`.

### R

This section explains what the core of the transforming R script
`piecewise_fd.R` does. This script should also work fine for stream
processing arbitrary amounts of plain text data. For example, if you have
100 GB of plain text files in a directory you could write:

```{R}
cat data/* | Rscript piecewise_fd.R > results.tsv
```

Then be patient.
This assumes that the data begins initially grouped by some column, and
processing the largest group doesn't exceed available memory. Some
techniques can work around these assumptions, but I won't mention them
here.

Here is `piecewise_fd.R`:

```{R}
CHUNKSIZE = 1e6L
# Should be larger than the max chunk size that one
# would like to process in memory.
# I checked ahead of time that the largest working chunk is
# around 800K rows.
# So make it larger than 800K.

# These parameters are specific to my particular analysis
col.names = c("station", "flow2", "occ2")
colClasses = c("integer", "integer", "numeric")
GROUP_INDEX = 1L  # Corresponds to grouping by station
SEP = "\t"


multiple_groups = function(queue, g = GROUP_INDEX)
{
    length(unique(queue[, g])) > 1
}


# Process an entire group.
# This function will change depending on the analysis to perform.
# grp is one group of the data frame
process_group = function(grp, outfile)
{
    #... specific to your analysis
       
    write.table(out, outfile, col.names = FALSE, row.names = FALSE
                , sep = SEP)
}


# Main stream processing
############################################################
# The variable queue below is a data frame acting as a FIFO that 
# changes dimensions as it reads data and processes groups 

stream_in = file("stdin")  # NOT stdin()
open(stream_in)
stream_out = stdout()

# Initialize the queue, a group of rows waiting to be processed.
queue = read.table(stream_in, nrows = CHUNKSIZE, colClasses = colClasses
    , col.names = col.names, na.strings = "\\N")

while(TRUE) {
    while(multiple_groups(queue)) {
        # Pop the first group out of the queue
        nextgrp = queue[, GROUP_INDEX] == queue[1, GROUP_INDEX]
        current = queue[nextgrp, ]
        queue = queue[!nextgrp, ]
        
        # Using try() allows each function to fail and keep going anyways.
        try(process_group(current, stream_out))
    }

    # Fill up the queue
    nextqueue = read.table(stream_in, nrows = CHUNKSIZE
        , colClasses = colClasses, col.names = col.names, na.strings = "\\N")
    if(nrow(nextqueue) == 0) {
        # This is the last group
        try(process_group(queue, stream_out))
        break
    }
    queue = rbind(queue, nextqueue)
}
```

I ran into a few gotcha's when writing this.  Hive represents missing
values with `\N` by default, so one needs to pass `na.strings = "\\N"` argument to
`read.table()`. Explicitly setting the `col.names` and `colClasses` fixed a
bug I ran into by ensuring consistency between how the data is stored in
Hive and in R.  Both of these things can be determined from Hive's metadata
store. Furthermore, very little of this R code is specific to my particular
analysis. In the future I would like to generalize and generate this code
rather than having to write it all explicitly.

Using `try(process_group(...)` from the R side allows the `process_group()`
function to fail silently. For this particular use case the analysis fails
for about half the groups because of issues in the data. This is completely
acceptable for my purposes.  However, for something that absolutely must
happen with every group you can remove the `try()` so that the failure will
propagate into the SQL query and the table will fail to be written.

### Conclusion

This post shows how to use R and Hive for `group by, apply` operations on
large data sets. The primary advantage is that each system does what it's
good at. Making R code parallel and scalable across vast amounts of text
data is certainly possible, but writing SQL is easier. Expressing a complex
analysis function as a native Hive UDF to process the groups with a `GROUP
BY` is also possible, but using a fast, robust implementation in an R
package is easier.

Another advantage of this approach is that it requires minimal installation
/ configuration. If you have data in Hive and R installed on the cluster
then you can use this technique today.

------------------------------------------------------------

> __Evolving Functions__ Let `f1(x)` and `f2(x)` be two different
> implementations for the same function. For example, one may be a parallel
> version that we generate based on the serial version. Usually the serial
> version will outperform the parallel version when the data is small. We can
> automatically and dynamically choose the faster implementation based on
> properties of the argument `x`, while also updating the models that estimate
> the required run time. For more details refer to
> `autoparallel/inst/beta/evolve.Rmd`.

------------------------------------------------------------

# Evolving functions

Tue Aug 29 10:37:03 PDT 2017

Imagine functions that get better as they are used. 
What if functions could adapt themselves to different arguments?

As a simple example, consider statistical computation on an $n \times p$
matrix $X$, ie. we have $n$ $p$ dimensional observations. Suppose we want
to call a function $f(X)$. There may be several possible efficient
implementations of a function $f$. Which is most efficient may depend on the
computer system and the values of $n$ and $p$.


## Current concepts

Learning functions already
exist; any function that caches results or intermediate computations will
be faster when called with the same arguments the second time. A prominent
and well executed example is R's matrix package, which caches matrix
decompositions for subsequent use.

Another example from different languages is JIT compilation. A function
is written in a general way, for example:

```{R}
dotprod = function (x, y)
{
    sum(x * y)
}
```

With JIT compilation when `dotprod()` is first called with both `x, y`
double precision floating point number then it will take time to compile a
version of `dotprod` specialized to these argument types, and then it will
call it on these arguments. When `dotprod()` is subsequently called with other
floating point arguments the same precompiled version will be discovered
and used again.

### When to use

Let's be very clear about when this should be used. Parallelism introduces
an overhead on the order of a ms, so there's no point timing operations
that require less time than that.

Some of the implementation may rely on `Sys.time()`, which has
a certain level of precision.

The instrumentation when put into place causes a small amount of overhead
(exactly how much?) that will affect the functions being timed. This means
that small timings will be unreliable.

No point in trying to go further with the precision.

## Implementation

`autoparallel` lets us improve functions using `evolve()`. The simplest
way to use `evolve()` is to pass multiple implementations as arguments.
Consider the following two implementations of linear regression which
extract the ordinary least squares coefficients.

```{R}

# Direct implementation of formula
ols_naive = function (X, y)
{
    if(ncol(X) == 2){
        X = X[, 2]
        mX = mean(X)
        my = mean(y)
        Xcentered = X - mX
        b1 = sum(Xcentered * (y - my)) / sum(Xcentered^2)
        b0 = my - b1 * mX
        c(b0, b1)
    } else {
        XtXinv = solve(t(X) %*% X)
        XtXinv %*% t(X) %*% y
    }
}

ols_clever = function (X, y)
{
    XtX = crossprod(X)
    Xty = crossprod(X, y)
    solve(XtX, Xty)
}

```

Before timing we may not be sure which of these implementations are faster.
Then we can pass both implementations into `evolve()` and let it figure
it out for us.

```{R}

library(autoparallel)

ols = evolve(ols_naive, ols_clever)

```

`ols()` is a function with the same signature (or a superset of the
signatures?) of `ols_naive()` and `ols_clever()`. 

## Ideas

- `ols()` will try different implementations. This implies that there must
  be different possible implementations to try.
- `ols()` times itself
- `ols()` detects easily parallelizable parts of code and can change them.

## A Statistical Problem

Every function evaluation produces an answer along with the accompanying
time. Suppose we have a finite set of $I$ implementations and $D$
sizes of data which determine the actual computational complexity.
Then we can model the wall time to run the function in a fully general way as:

$$
    t = \mu(i, d) + \epsilon(i, d)
$$

$\mu(i, d), i \in I, d \in D$ is the true mean time while $\epsilon(i, d)$
is a random variable.

The overarching goal is to choose an implementation $i \in I$ which
minimizes the time required to solve a problem of size $d \in D$.

Looking back at the `ols()` example, $I$ = `{ols_naive, ols_clever}`, while
$D$ could be anything, but suppose we are only interested in problems with
$n \in \{ 100, 500 \}$ and $p \in \{1, 30\}$.

This is an updating / online learning problem.


```{R}

library(microbenchmark)

n = 100
p = 1
ones = rep(1, n)
X = matrix(c(ones, rnorm(n * p)), nrow = n)
y = rnorm(n)

beta_naive = ols_naive(X, y)
beta_clever = ols_clever(X, y)

max(abs(beta_naive - beta_clever))

microbenchmark(ols_naive(X, y), ols_clever(X, y), times = 10)

```

With these numbers the naive version is slightly better.


## Builtin functions

Suppose one wants to do the same timing and predictions for a function in
base R. Take `crossprod(X)` as an example, which computes the matrix $X^T
X$. Let $X$ is an $n \times p$ matrix of real numbers. `crossprod(X)` can
use the symmetry of the result, so it needs `n p (p + 1) / 2` floating
point operations.

```{R}

# Include y to match the signature for crossprod()
crossprod_flops = function(x, y)
{
    n = nrow(x)
    p = ncol(x)
    data.frame(npp = n * p * (p + 1) / 2)
}

trace_timings(crossprod, metadata_func = crossprod_flops)

n = 100
p = 4
x = matrix(rnorm(n * p), nrow = n)
crossprod(x)

n = 200
p = 50
x = matrix(rnorm(n * p), nrow = n)
crossprod(x)

```

## Design for Trace based timings

The `metadata_func` function captures the relevant metadata for an
operation. To make a custom `metadata_func` functions, as with the
`crossprod_flops()` above, it seems reasonable to match the signature of
the function which is being timed. This could be verified. Then the design
issue is how to access and use these variables from within the functions
that are used in `trace()`? Note that these functions cannot have any
parameters. Therefore we must discover the arguments from within the
functions themselves.

If the formal parameters match then we can directly lift the arguments from
the calling function. Some care is needed to respect lazy evaluation. Here
are some considerations. In the following let `f` be the function and `am()` be the
corresponding argument metadata function with the same signature as `f`.

```
f = function(a) ...
am = function(a) ...
```

`f(x)` is the same as `f(a = x)`, so we can evaluate `am(a)`.
Similarly, `f(g(x))` lets us evaluate `am(a)`. Thinking more on this, we
can just evaluate the default signature. One issue that may come up is
finding the wrong values inside the intermediate closure. 
Another issue is where to evaluate the signature? Inside the body of the
function where the tracing happens. `metadata_func()` does not exist
there. We can put it there.

The more general case is a single function such as the default
`length_first_arg()`, which must be capable of handling different argument
signatures. First off we need to assume that there is at least one
argument, since otherwise we can't make any predictions based on
characteristics of the arguments.

For the trace based method, one way to implement `length_first_arg()` is as
a function with zero parameters that reaches through to its parent. This
approach won't work for the S3 methods currently using `...` though. So maybe the
best way is to rewrite it all to use the trace implementation, since that
is more general. Then I don't have to have two implementations.


## Extensions

I could cache the functions and the models on the user's disk for reuse in
new sessions. Duncan has suggested that we even cache them centrally, ie.
the user program sends in metadata, system info, and possibly
implementations to a central server.

## Related ideas

Is there a way to "merge" functions? In the OLS case for least squares I
give three implementations. Some may work better on special cases. Could we
pull all of that logic into one function? That's somewhat what I'm doing
here.

------------------------------------------------------------

> __Task Parallelism__ I've built some of the infrastructure and analysis
> here based on CodeDepends, but I haven't come across any compelling use
> cases to motivate an actual implementation including code generation of
> `mcparallel` and `mccollect`. I've written this up in
> `phd_research/expression_graph` and implemented parts in
> `autoparallel/inst/beta/codegraph`.

------------------------------------------------------------

\section{Introduction}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

The idea behind code analysis is to treat the code itself as a data
structure. Then ``Programming on the language'' opens up rich possibilities.
This is an old idea, both the R and Julia language references cite Lisp
as the inspiration \cite{Rlang} \cite{bezanson2014julia}.

Compilers have used all manners of static analysis and
intermediate optimizations to create more efficient code. Interpreted
languages are much more limited in this respect. This project explores
the use of an alternative evaluation model to improve performance while
preserving language semantics.

The evaluation model for interpreted languages is simple. Each
expression of code is evaluated in the order that it appears in a text file. Informally
each expression is a line of code. This can be
viewed as a set of constraints on the evaluation order of the expressions:
\begin{enumerate}
    \item expression 1 executes before expression 2
    \item expression 2 executes before expression 3
    \item $\dots$
\end{enumerate}
What if these constraints are relaxed? Suppose expression 1 defines the variable
\texttt{x}, which is not used until expression 17. Then one has the
constraint:
\begin{enumerate}
    \item expression 1 executes before expression 17
\end{enumerate}
This can be generalized into a directed graph which we'll refer to here as
the \textbf{expression dependency graph} by considering expressions as
nodes and constraints as edges. The edges are implicit based on the order
of the statements in the code. Add an edge from $i \rightarrow k$ if
expression $k$ depends on the execution of expression $i$.  It's safe to
assume $i < k$, because expressions appearing later in a program can't
affect expressions which have already run. Hence the expression graph is
acyclic, i.e. a DAG.

Scheduling execution based on the expression graph allows some expressions to execute in
parallel. For example, the following adjacent lines are independent, so
they can be computed simultaneously:

\begin{verbatim}
sx = sum(x)
sy = sum(y)
\end{verbatim}

Mathematically, the standard evaluation model is a total ordering on the
set of expressions in the code. The dependency graph is a partial ordering.

\section{Literature Review}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\label{sec:lit}

The expression graph proposed above is similar to 
use-definition and definition-use chains. A definition-use chain consists
of all expressions using a variable following the definition of that
variable. This amounts to a subset of the edges in the expression graph,
since it's possible that expressions depend on each other without
variables. For example, consider the following R code to save a plot to a
pdf:
\begin{verbatim}
pdf("xy.pdf")
plot(x, y)
title("x and y")
dev.off()
\end{verbatim}
These expressions depend on each other, but only \texttt{plot(x, y)} uses variables.

The use-definition chain has been around since at least 1978
when it was used to remove dead (unused) code \cite{kennedy1978use}.
Code usefulness is defined recursively; a computation is useful if the result is
used later by another computation. This is combined with the ``base case''
of usefulness, a set of operations considered
intrinsically useful. This author considers calls to subroutines and branch
test instructions as intrinsically useful. For data analysis we might take
this base case and tweak it a little- define expressions in a data analysis
script as intrinsically useful if they have a side effect, for example
saving data to disk.

More general than the use-definition chain is the program dependence graph (PDG)\cite{ferrante1987}:
\begin{quote}
    A PDG node represents
    an arbitrary sequential computation (e.g., a basic block, a
    statement, or an operation). An edge in a PDG represents
    a control dependence or a data dependence. PDGs do not
    contain any artificial sequencing constraints from the
    program text; they reveal the ideal parallelism in a
    program. \cite{sarkar1991automatic} 
\end{quote}
\cite{sarkar1991automatic} goes on to make the practical distinction between ideal
parallelism and useful parallisism. Overhead implies that the two often
differ.
The expression graph proposed here differs from the PDG since it allows the permutation of
operations in a basic block.

The hierarchical task graph (HTG) was introduced in \cite{girkar1992automatic}
to detect task parallelism in source code for use in compilers.
Similar to the others, it examines the control flow for a fine grained
parallelism. They allow `compound nodes' containing nested HTG's.
\cite{cosnard1995automatic} describe constructing a task graph based on
annotating the source code the program.
\cite{adve2004parallel} presents a model for predicting the run time of
programs based on a task graph. 

The literature cited in this section focuses primarily on compiled
languages along with careful analysis of control flow. Most examples and
applications presented along with these papers are for well-defined
algorithmic problems. These algorithmic problems are often quite different
than a high level data analysis script which may call down into several
different algorithms.

\section{Languages Requirements}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

We can consider building the expression graphs described above for languages that are
\begin{itemize}
    \item open source
    \item used for data analysis
    \item high level
    \item interpreted
    \item enable metaprogramming
\end{itemize}
Metaprogramming warrants more explanation. This refers to programmatically
inspecting and potentially modifying code from within the language.  It is
needed to determine when variables are created and used, among other
things.  The current popular languages satisfying these requirements are
Python, Julia, and R.

The basic unit to analyze is a single code expression.
Most expressions use symbols, aka variables or names.
An expression may do any combination of the following actions:
\begin{enumerate}
    \item Define new symbols: \texttt{x = 10}
    \item Use existing symbols: \texttt{sin(x)}
    \item Redefine existing symbols: \texttt{x = 20}
\end{enumerate}

\begin{table}[]
\centering
    \caption{Sorting \texttt{x} in place}
\label{tab-sort}
\begin{tabular}{ll}
    \textbf{language} & \textbf{code}        \\
\hline
    Python   & \texttt{x.sort()}    \\
    Julia    & \texttt{sort!(x)}    \\
    R        & \texttt{x = sort(x)}
\end{tabular}
\end{table}

Table \ref{tab-sort} shows idiomatic code to sort a numeric vector.
The Julia and Python methods modify their arguments in place.  From a
computational standpoint this is great, since it allows the implementations
to use more space efficient sorting techniques. However, from a code
analysis standpoint this behavior is undesirable, since it means that we
need to assume generally that every method call in these languages both
uses and potentially modifies the object. Since data analysis scripts mainly consist of
function and method calls this will excessively constrain the problem.

It may be possible to recursively examine all functions and methods which
are used, but this is not ideal for a couple reasons. First, it would
require analyzing the underlying library code, which is orders of magnitude
more code than what the user has written. Second, eventually we'll get to
compiled code which requires totally different methods. For example, C code
parsed with LLVM
can be used to programmatically generate use-definition chains
\cite{lattner2004llvm}.

Hence functional programming and pass by value semantics make constructing
graphs much more feasible. The R language is ideal in this respect.

\section{Related Work}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Bengtsson's \texttt{future} package provides a mechanism for
asynchronous assignment and evaluation of R expressions \cite{R-future}. Once the
expression graph is created it might be possible to use similar mechanisms
for evaluation.

Hester's covr package \cite{R-covr} checks unit test coverage of R
code. It is a practical example of computing on the language,
programmatically modifying the code by recording calls as they are made.
He pointed out the necessary distinction between AST's, parse trees, and
``lossless syntax trees''.
\footnote{\url{https://news.ycombinator.com/item?id=13628412}} To inject
code into a script one needs to be very careful to preserve structure lost
after parsing, ie.  comments and formatting. This is a non-trivial task.

A similar strategy of recording calls should work to collect timings and
resource usage for each expression and for functions called with various
data sizes. Then we can potentially use this to change the execution when
it becomes efficient to do so.  This resembles something like Profile
Guided Optimization (PGO). 

Maybe a simpler way to do this is to just use the built in profiler. Use
the results to determine whether parallelization is worth it, and maybe set
some bounds for expected performance changes if one uses various forms of
parallelism.  Statistical methods could potentially be used for this.
Run it many times, collecting profiling results for various values and use
this as the training data to produce a rule such as: if $n > 10^6$ then run
it as multicore.

The vignette in Tierney's \texttt{proftools} package has some nice examples
of visualizing profiling data \cite{R-proftools}. The call graphs and
related visualizations are conceptually similar to what might be done with
the expression graph.  \texttt{profvis} integrates with the IDE to indicate
the actual line of source code along with the related timing info
\cite{R-profvis}.

Xie's \texttt{knitr} facilitates reproducible computations for
chunks of code in Rmarkdown documents \cite{R-knitr}. One feature it enables is caching,
ie. it doesn't need to run a chunk of code if nothing has changed. One can
manually specify the chunk dependencies by relative or absolute indices,
ie. -2 for the chunk 2 blocks in front of the current chunk, or 1 for the
first chunk. This seems unreliable because it requires the user to
accurately infer the dependency information, and it doesn't automatically
adjust if one inserts new chunks in the document.

Knitr also has an \texttt{autodep} option to infer this dependency
information. This works by comparing the global variables existing before
and after running the code in each chunk. It stores this information in
special files. So it doesn't use any static analysis of the code.

But the structure of knitr blocks here is actually very appealing- this is
a great use case for the parallelism. Why not evaluate the chunks in
parallel if possible? The case for Jupyter notebooks is similar, but would
require an equivalent code dependency graph for Python.

\section{Graph Construction}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To start off we make two assumptions on the program. First, assume it's
correct, meaning that it will run sequentially without errors.
Second, every expression should be strictly necessary. This can be achieved
through a preprocessing step removing dead code.

The expression graph and related data structures are related to the parsed
script, referred to as the \textbf{parse tree}. The expression
graph is a function of the parse tree. Since the parser
doesn't care about non significant white space and comments,  different
scripts can produce the same parse tree.  Many parse trees can give rise to
the same expression graph. For example, the expression graph shouldn't care if one uses
\texttt{=} or \texttt{<-} for assignment. Nor will it care about the
ordering of two adjacent lines binding a symbol to a literal constant:

\begin{verbatim}
a = 1
b = 2
\end{verbatim}

Therefore we lose information by converting from a parse tree to an
expression graph.

``Expression'' here refers more specifically to top level expressions, the children of
the root node in the parse tree. For example, \texttt{for} and
\texttt{while} loops are function calls in R, and the expression graph
treats them the same as any other function calls. This means that we do not
currently examine control flow at all. It is possible to examine
expression graphs recursively; conceptually the ideas will be similar.

Figures \ref{fig:ast} and \ref{fig:codegraph} illustrate the 
parse tree and expression dependency graph for the four lines of code in
listing \ref{list:ab}.  Edges 1 and 3 in figure \ref{fig:codegraph} represent the
respective uses of the variable \texttt{n} and \texttt{x}.  Edge 2 comes
from the redefinition of \texttt{n}.  Edge 5 propagates the most recent
definition of \texttt{n}.  The least obvious is edge 4, which is necessary
to respect R's lexical scoping semantics since \texttt{x <- rnorm(n)} uses
the first definition of \texttt{n}. The general rule here is that all
statements using one version of the variable \texttt{n} must execute before \texttt{n}
can be redefined.

The dashed edges in figure \ref{fig:codegraph} are redundant for representing
expression dependence given the other edges. Indeed, the code in
listing \ref{list:ab} must run sequentially. One may wish to remove such
redundant edges, especially for visual presentation of a larger program.

\lstinputlisting[language=R, caption=Simple script, label=list:ab]{../experiments/ast/ab.R}

\begin{figure}
\centering
\begin{subfigure}{.6\textwidth}
    \centering
    \includegraphics[width=.8\linewidth]{../experiments/ast/ast.pdf}
    \caption{Parse tree}
    \label{fig:ast}
\end{subfigure}%
\begin{subfigure}{.4\textwidth}
  \centering
  \includegraphics[width=.8\linewidth]{../experiments/ast/codegraph.pdf}
  \caption{Expression dependency graph}
  \label{fig:codegraph}
\end{subfigure}
\caption{Different representations of the script in Listing \ref{list:ab}}
%\label{fig:test}
\end{figure}

The existence of some edges may depend on conditional statements which can't
be known until run time. In this case the conservative and correct way to
handle the situation is to add the edges in question, because adding edges
cannot constrain the problem beyond the constraints imposed by sequential
execution. For example, in the following code one assumes that the
expression \texttt{x <- 10} will run.

\begin{verbatim}
# coinflip() randomly returns TRUE or FALSE
if(coinflip()){
    x <- 10
}
\end{verbatim}

\section{Task Based Parallelism}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

It's reasonable to try to improve code performance if slow speed affects
many users. For scripts, superficially it might appear that few people are
affected. Indeed, if a researcher writes one script that takes a couple
minutes to run, and they run it a couple times then it doesn't matter much,
and there's no point in attempting to accelerate it.  However, 
scripts can be used in more serious ways.  For example, scripts
can be used as Extract Transform Load (ETL) tools that run as batch jobs
every day or every hour. Then the script runs many times, so it's important
to realize more performance. For ease of use and maintainability it's nice
to have automatic tools to accelerate the performance. Then one can write
simple scripts and leverage a powerful tool to gain parallelism. This is
preferable to maintaining many complex scripts since it requires less
expert knowledge.

As of 2009, most efforts to parallelize R have focused on the lower level
programming mechanisms \cite{schmidberger2009state}. These needed to be in
place before any higher level automatic detection could be built and
function.

Let $k$ be the number of cores on a machine.
To accelerate code using this single machine the best possible case is if
we can keep all $k$ cores busy at once. This will happen if there are $nk$
expressions which can be independently scheduled for some positive integer
$n$. 
On a two core machine that script might look something like:

\begin{verbatim}
# These could be run in parallel
a = long_running_func()
b = long_running_func()
\end{verbatim}

The worst possible case is if the second long running computation depends
on the first, and everything else depends on the second. Then it must run
in serial so parallelism can't help.

\begin{verbatim}
a = long_running_func()
b = long_running_func2(a)  # depends on a
# Now perform many operations on b
\end{verbatim}

\subsection{Static Execution}
\label{sec:static}

If overhead and expression run time are approximately known then the
question of optimal execution for the complete expression dependency graph
can be framed as a scheduling optimization problem and solved statically.
The objective function to minimize is the total wall clock time to complete
execution. Constraints come from the dependency graph and that at most $k$
cores may be active at one time.

To consider an alternative evaluation model the overhead required to
parallelize an expression should require less time than running the
expression itself. Rounding to orders of magnitude, here are some rough
times for reference executing on a modest machine. Simple R expressions
take $10^{-7}$ seconds to evaluate. Using a system level parallel fork
requires $10^{-3}$ seconds of overhead. Evaluation on an existing local
socket cluster takes $10^{-4}$ seconds. Then either of these well
established methods for parallelism in R won't become efficient until the
code under evaluation takes on the order of $10^{-3}$ seconds.
These timings include latency for interprocess communication on a single
machine. Bandwidth is also an issue, since serializing large amounts of
data between processes, i.e. millions of floating point numbers, will impact
performance. For example, listing \ref{list:overhead} squares each element
of a vector of one million floating point numbers. Memory transfer overhead causes
a parallel evaluation to take more than an order of magnitude more time
than the single threaded serial version. 

Technical solutions such as threading and shared
memory have the potential to reduce these sources of overhead.
Issues of latency and bandwidth generally become more complex for different
architectures such as distributed systems and GPU's
\cite{matloff2015parallel}.

\subsection{Dynamic Execution}
\label{sec:dynamic}

Alternatively a dynamic execution model can be used. This relies on a
master / worker architecture. The reference version could be a multicore
system which forks to evaluate expressions.  At a high level, the master
runs an event loop that pops expressions from the top of the expression
dependency graph.  This approach is appealing because it dynamically
balances the load among workers.

Here's an algorithm: Insert the artificial node 0 representing the beginning
of the script, so that nodes without parents now have node 0 as a parent. Mark
these direct descendants of node 0 as ready. Let the workers begin evaluating
these expressions.

\begin{enumerate}
    \item Event loop checks to see if any are done.
    \item Expression $e_i$ finishes and the results are available again
        on master.
    \item For each expression $e_j$ which depends directly on $e_i$: check
        if $e_j$ has no other existing parents then mark it as ready.
    \item Remove $e_i$ from the graph.
    \item Free workers begin executing any of the nodes that are marked as ready.
\end{enumerate}

There's some nuance here by trying to keep each of $k$ workers as busy as
possible while still respecting the constraints. I.e. there may be
bottlenecks where only one worker can be active, but after that all the
others can go.

This algorithm could also be refined into a priority queue by keeping the ready
nodes in a heap, with the values determining the heap order as the number
of expressions that depend on that expression, directly or indirectly. This
is a little naive- it would be better to have timings of the code and do
something more optimal in terms of reducing run time.

The process forking every time will be quite inefficient. The more intelligent
thing to do is `pipeline' the operations, and send whole related blocks of
expressions to individual processes to evaluate.

\section{Challenges}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

R's flexibility makes code analysis challenging in some cases.

\subsection{Reproducibility}

Reproducing random streams allows one to perform the exact same random
computation. This is useful for investigating anomalous simulations, and
for many other cases. The R documentation for \texttt{parallel::mcparallel}
explains how this works in the case of parallel forking:

\begin{quote}
     The behaviour with ‘mc.set.seed = TRUE’ is different only if
     ‘RNGkind("L'Ecuyer-CMRG")’ has been selected.  Then each time a child
     is forked it is given the next stream (see ‘nextRNGStream’).  So if
     you select that generator, set a seed and call ‘mc.reset.stream’ just
     before the first use of ‘mcparallel’ the results of simulations will
     be reproducible provided the same tasks are given to the first,
     second, ...  forked process.
\end{quote}

If a dynamic model is used as described in section \ref{sec:dynamic}, then
reproducing the exact computation may not be possible, since the code may not execute in the
same order. However, if this level of reproducibility is important then one
can force it through manually seeding the functions that matter. For
example:
\begin{verbatim}
critical_random_func()
\end{verbatim}
becomes
\begin{verbatim}
{set.seed(123); critical_random_func()}
\end{verbatim}

\subsection{Dynamic Evaluation}

Correct, legitimate code can be written that depends on the results of
dynamic evaluation. Indeed, some symbols may not currently exist. This is
more common inside package code that defines and uses many functions, and
less common in scripts.  Here's an example:

\begin{verbatim}
f = function() 0        # 1
g = function() f() + 1  # 2
f = function() 10       # 3
g()                     # 4
\end{verbatim}

The last line returns 11, since it uses the most recent version of \texttt{f()}.
An expression dependency graph that does not correctly handle dynamic
evaluation here will consist of these edges:

\begin{verbatim}
1 -> 2, 1 -> 3, 2 -> 4
\end{verbatim}

So the statements could be written in the following order, which respects
the partial order:

\begin{verbatim}
f = function() 0        # 1
g = function() f() + 1  # 2
g()                     # 4
f = function() 10       # 3
\end{verbatim}

In this case the call to \texttt{g()} will incorrectly return 1 instead of 11.
Hence there is a ``hidden'' dependency implicit here: \texttt{3 -> 4}.
This comes back to lexical scoping rules, since we need to look up the
correct \texttt{f()}.

One possible way to get around this is to recursively inline all user
defined functions, and then perform the expression dependency analysis. One
substitutes the bodies of \texttt{g(), f()} so the code presented above
becomes simply \texttt{10 + 1}. This also has the effect of removing user
defined functions from the expression graph.

\subsection{Mutable Objects}

Environments and reference class objects in R are mutable. They are a
special case and must be handled carefully. One way to handle them is to
treat any access of one of these objects as a redefinition. This resembles
the conservative approach one would have to take for Python or Julia
methods, and could result in a similar outcome of having too many
constraints.

With environments one could refer to all variables specifically through
(environment, symbol) pairs. Through these pairs all variables in
environments essentially act like regular variables, and variables in the
global environment are just a special case.

\subsection{Non Standard Evaluation}

The R code \texttt{lm(y \textasciitilde x, data = d)} is ambiguous because
\texttt{x, y} may be global variables or they may be columns in the data
frame \texttt{d}. CodeDepends doesn't detect the dependency on variables
\texttt{y, x} because of non standard evaluation (NSE). For interactive use
NSE can be convenient, but it comes at the cost of referential transparency
\cite{wickham2015advanced}. The programming model in this case is no longer
functional, which makes code dependency analysis much more difficult.

A related case to NSE is user code that operates directly on the language
through expression manipulation. At this point we're metaprogramming on
code that does metaprogramming, which sounds like a dangerously bad idea.
We're better off leaving it alone or operating on code that it generates,
if possible.

As before, the conservative approach is to add edges and dependencies when in
doubt. So in the code above one assumes that all of the variables
\texttt{x, y, d} will be used.

\subsection{Side Effects}

As mentioned in section \ref{sec:lit}, it's difficult to recognize the
dependence structure with plotting commands. One way to handle this is to
use a preprocessing step to collapse all steps modifying the graphics
device into one block of code. This can be implemented by scanning the
script and adding braces around the lines of code that open and close
graphics devices, for example:

\begin{verbatim}
{   # Added by preprocessor
pdf("plot.pdf")
... # plot(), title(), text(), etc.
dev.off()
}   # Added by preprocessor
\end{verbatim}

This block will then be executed together as one top level expression.

\section{Conclusion}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

This work introduced the expression dependency graph and presented an
alternative execution model for R code based on dependency analysis.
From my experience examining and running data analysis scripts, 
data parallelism is far more important than task parallelism. Indeed, in
the course of examining real world scripts for this I couldn't find any
examples where this approach would result in speedup justifying the
overhead.  However, if lighter weight threads or shared memory were
possible in R then the relative overhead could be made orders of magnitude
smaller, and this task based approach to parallelism should be revisited.

Future work will explore other uses for the expression graph beyond
parallelism. For example, the expression graph could be used for
educational purposes or for debugging.

On a broader note, this is about embedding more intelligence into the 
system. Many languages have mechanisms or third party tools for explicitly
requesting asynchronous evaluation. These typically require changing the
code. This introduces complexity, makes maintenance more difficult, and
makes the code less portable.  It's more convenient to have one version of
the code which can be passed to a system which can analyze the code and
``do the right thing'', adjusting to different platforms, work loads, and
data sizes on the fly. 

------------------------------------------------------------

> __Column Use Inference__ `read_faster` analyzes code to
> find the set of columns that are used and transforms the code to a version
> that only reads and operates on this set of columns.

------------------------------------------------------------

We can modify code to make it more
efficient. Consider this simple script:

```{R, eval = FALSE}

d = read.csv("data.csv")

hist(d[, 1])

```

This script only uses the first column of `d`, which means that all the
other columns were unnecessary. If `data.csv` is sufficiently large, and it
has many columns, then this program will spend an excessive amount of time
reading data that are never used.

```{R}

library(CodeAnalysis)

script = parse(text = '
    d = read.csv("data.csv")
    hist(d[, 2])
    ')

read_faster(script)

```

## Static Analysis

`read_faster()` uses static code analysis to infer which columns are
required to run the complete script.  For example, we can statically
analyze literals and evaluate simple functions such as `c()`

```{R, eval = FALSE}
mtcars[, c(1L, 3L)]
mtcars[, "mpg"]
mtcars$mpg
```

We cannot statically analyze code where the value isn't known until
runtime.

```{R, eval = FALSE}

# TODO: Decide. Currently this fails, but could just as easily have it be a
# warning.
read_faster(parse(text = '
    d = read.csv("data.csv")
    hist(d[, rpois(1, 1)])
'), "d")

```

### Inferring column names

If the code does not use subsets based on column names then it doesn't
matter what the column names are. 

If the column names are initially specified, ie:

```{R, eval = FALSE}

d = read.table("data.csv", col.names = c("a", "b", "c"))

```

then we know the column names.

Lastly, if `header = TRUE` we can try to look at the data itself to infer
the column names. We can only try, because the location of the data may
not be the same as the location where `read_faster()` is called.

## Future Work

### Necessary 

_These tasks should be completed before a public release._

Verify the indices subsetting `d` can be computed at the time of
static analysis.

Check if any commands imply that the whole data set must be loaded. For
example:

```{R, eval = FALSE}
d = read.csv("data.csv")
d[, 5] = 2
write.csv(d, "data2.csv")  # Uses all columns of d
```

The safe thing to do anytime we see a use of `d` which is not a subset is
to assume that it will then require all columns.

Handle variables which are redefined. This could likely be done through a
single static assignment (SSA) preprocessing step. For example, the
following is problematic because we must restrict the code analysis and
transformations to `x` before it is redefined:

```{R, eval = FALSE}

x = read.csv("data.csv")
print(x[1, 1])
x = list(1, 2, 3)
print(x[[1]])

```


### Nice to Have

_These tasks are less critical._

Through constant propagation we can also handle variables defined from
literals:

```{R, eval = FALSE}
cols = c("cyl", disp")
mtcars[, cols]
```

Account for indirect use of variables. The following should infer that the
4th column is used.

```{R, eval = FALSE}
d = read.csv("data.csv")
d2 = d * 2
d2[, 4]
```

Read subsets without corresponding variable assignments, for example:

```{R, eval = FALSE}
hist(read.csv("data.csv")[, 2])
```

More complicated forms of assignment. Haven't verified which work.

```{R, eval = FALSE}
a = b = read.csv("data.csv")
```

Further column selection operations including non standard evaluation such
as using `subset`, or `lm(y ~ x, data)`.

TODO: Return to this point, continue editing down into user facing manual.
Design stuff can live in the other doc.

## Implementation

How can we tell which columns are used?


Fri Sep 22 10:31:23 PDT 2017

For the moment I'm ignoring NSE such as `subset`.

Thinking now that it's fine to depend on `data.table`.
`data.table::fread` has a `select` parameter for column names. It would be
more convenient for our purposes here if `select` took an integer vector of
the column indices instead. Indices are more general because:

- Not every text file has column names
- Not every data frame has meaningful column names
- Column names may not be unique

One approach is to take all the uses of column names and map them into
integers.
The code will go through three representations then:

__Original__ including mixed names and integers:

```{R, eval = FALSE}

mpg = mtcars$mpg
cyl = mtcars[, 2]
disp = mtcars[, "disp"]
wt = mtcars[[5]]

```

__Name Replacement__ substitutes the names with integers, and converts all
`data.frame` subsetting commands into single `[`. Assume that we know the
column names.

```{R, eval = FALSE}

mpg = mtcars[, 1]
cyl = mtcars[, 2]
disp = mtcars[, 3]
wt = mtcars[, 5]

```

As we replace names we can update the set of variables which are used, so that
after processing all statements we know which are used.


__Subset mapping__ maps the original indices to corresponding indices in the
smaller `data.frame`. The index map is a sorted integer vector of the
columns that are used. This step cannot happen with the previous because
it's necessary to first know all the columns which will be used.

```{R, eval = FALSE}

index_map = c(1, 2, 3, 5)

.mtcars = fread(..., select = index_map)

mpg = .mtcars[, 1]
cyl = .mtcars[, 2]
disp = .mtcars[, 3]
wt = .mtcars[, 4]   # This one changes

```

## Details

__Nested subsetting__

Suppose that `x` is the data frame of interest. Consider the following
reasonable code:

```
x[x[, "d"] > 10, "b"]
```

Replacing names gives us the following in standard form:

x[x[, 4] > 10, 2]

Because there is nested subsetting we need to respect the structure of the
parse tree to correctly substitute these variables with indices.

TODO: What is the issue in my mind? I don't want this to happen:
```
# First step updates the inner
x[x[, 4] > 10, "b"]

# Second step updates the outer based on the original statement
x[x[, "d"] > 10, 2]
```

This leaves us with the task of having to merge the parse trees. We
definitely want to avoid this. So we need to update the tree in place,
incrementally. In the more general case it may happen that the locations of
the parse tree change as it is modified.  Then we'll need a way to guarantee
that nothing is overwritten. Maybe applying the changes depth first?


## Limitations

What are the limitations of the approach that I've just outlined? 

It's really only designed for data frames. So it would be a little
dangerous if I _think_ something is a data frame, when in fact it's a list.
Then if I replace `[[` and `$` with `[` it won't work. I can get around
this by focusing on functions that return data frames, for example
`read.csv()`.

I haven't yet considered subsetting rows, there may be a way to do that
efficiently.  A common way is to subset based on the value of some column.
I could do this by keeping on open file pointer, reading a chunk of the
data, subset it, add that subset to a list, then rbind the subsets
together. This potentially lets R quickly process files larger than memory.

How to get every column which is used when new copies of the data frame
are created? For example:

```{R, eval = FALSE}

mtcars2 = mtcars[possible_subset, ]

# Now `gear` column must be read in.
mtcars2$gear

```

Stepping back, R has many ways to write programs. To simplify tasks here we
first put the code into a canonical form, and then do "surgery" on it.


## Side Notes


info = lapply(code, CodeDepends::getInputs)

# The CodeDepends output says when `read.csv` func is called, which is
# helpful. But it doesn't let me see if the result of `read.csv` is
# assigned to a variable, which is what I need.

code2 = quote(x <- rnorm(n = read.csv("data.csv")))

CodeDepends::getInputs(code2)

------------------------------------------------------------

> __Basic Parallelism__ `parallelize` efficiently distributes a single large
> object `x` and executes code in parallel based on the presence of the
> symbol `x` in the code. `benchmark_transform` simply replaces `lapply` with
> `parallel::mclapply` if benchmarks indicate it's faster based on a t test.

------------------------------------------------------------

# Interactive

This vignette discusses the interactive use of this package.

Suppose you have some large or unwieldy object in R which can conceptually
be split into parts, such as the rows of a data frame or the elements of a
list. You are analyzing this object, perhaps writing functions and
debugging them as you go. The code takes too long to run. Most of what
you're doing could happen in parallel after an appropriate split, but you
don't want to worry about all the issues that can arise with parallel code
when you're in the middle of your interactive analysis. You want a system
to manage all the details of the parallelism for you, so that you can focus
on the analysis. The `parallel_evaluator` (subsequently referred to as the
_'evaluator'_) is a system to manage the details.

## Basic Example

We'll start with a basic example.

```{r}

library(autoparallel)

x = list(1:10, rnorm(10), rep(pi, 10))

do = parallelize(x)
do

```

Calling `parallelize` split `x` into approximately equal parts
so that one can run code in parallel using the resulting evaluator `do`.

Calling `lapply` on a list through `do` produces the same result as the
base R case:

```{r}

lapply(x, head)

do(lapply(x, head))

```

There's nothing special about the use of `lapply()` above. We can evaluate
arbitrary code.

FEEDBACK: The current implementation for the parallel evaluator only looks
for variables in the global environment, which is why I'm using `<<-`
(because of how knitr evaluates).  I _could_ write a version that uses
`dynGet()`, but this would be more complicated.

```{R}

y <<- 20
z <<- 30
do(y + z, verbose = TRUE)

```

`y + z` uses the variables `y` and `z`. The evaluator detects this and
sends them over, saving the user from having to do this manually.

## Interactive

The evaluator is designed for interactively building functions and analysis
on large data sets, or data sets that take too long to run. The interactive
feature is sending variables, including functions, from the manager's
global workspace to the parallel workers every time they are used. This
allows us to see the results of the improved / debugged versions of the
functions as we work on them.

```{r}

# An analysis function
myfun <<- function(x) x[1:2]

do(lapply(x, myfun))

# Oops I actually need the first 4
myfun <<- function(x) x[1:4]

# Now we see the new results of myfun
do(lapply(x, myfun))

```

## Limitations

`autoparallel` is not currently designed to work with multiple large
objects.  Rather, it was designed for a single large object to be
distributed to the workers when the evaluator is created.  The following
code will be slow because it serializes a large (400 MB) object to each of
the workers:

```{r, eval = FALSE}

# Any large R object
big = 1:1e8

object.size(big)

# BAD IDEA: this sends `big` over every time
do(sum(big + x[[1]][1]))

```

FEEDBACK: I could check the size of the objects before exporting them, and
handle it if they're too large.

## Details

Under the hood, the evaluator is a closure with a couple attributes. The
most notable attributes are the variable name and the cluster. We can
inspect all this by printing the evaluator as a function.

```{R}

print.function(do)

```

The default simplifying function is `c()`. We can also bring back results
without simplifying.

```{R}

do(lapply(x, head), simplify = FALSE)

```

`do` sent the code to 2 different R processes for evaluation, so we will
always see a list of length 2 before the results are simplified.


## Cleaning up

When finished it's a good idea to shut down the cluster. This also happens
automatically when the R session is terminated.

```{r}

stop_cluster(do)

```

## Working with many files

A realistic example is working with many files simultaneously. The US
Veterans Administration (VA) Court appeals are one such example. Each file
contains the summary of an appeal.
One can download a handful from the VA servers as follows:

```{r, echo = FALSE}

# Used on my local machine only
datadir = "~/data/vets/appeals_sample"

```

```{r download, eval = FALSE}

datadir = "vets_appeals"
dir.create(datadir)

fnames = paste0("1719", 100:266, ".txt")
urls = paste0("https://www.va.gov/vetapp17/files3/", fnames)

Map(download.file, urls, fnames)

```

The file names themselves are small, so we can cheaply distribute them
among the parallel workers.

```{r}

filenames = list.files(datadir, full.names = TRUE)
length(filenames)

do = parallelize(filenames)

```

The following code actually loads the data contained in the files and
assigns the result into `appeals` on the cluster. It's efficient because
the reads happen in parallel, rather than creating a bottleneck in the
manager process. Furthermore, by having the workers do their own loading we
do not have to serialize the data between processes.

```{r}

do({
    appeals <- lapply(filenames, readLines)
    appeals <- sapply(appeals, paste, collapse = "\n")
    appeals <- enc2utf8(appeals)
    NULL
})

```

The braces along with the final `NULL` are necessary to avoid transferring
the large data set from the workers back to the manager.

The code above only assigned `appeals` to the global environment of the
workers. It does not exist in the manager process.

```{r}

"appeals" %in% ls()

```

However, if we subsequently create a variable called `appeals` in the
manager process then the evaluator will export it to the cluster,
overriding the existing one.  

```{R}

ten <<- 10
do(ten + 1, verbose = TRUE)

```

The evaluator allows us to execute the same code that is
used for serial R. Again, we see a vector of length 2 because we're running
the code on chunks of the data residing in 2 R processes.

```{r}

do(length(appeals))
do(class(appeals))

```

We may want to look more closely at those cases which have been remanded
for further evidence. If they're a reasonably small subset we may choose to
bring them back into the manager process for further non parallel analysis.
This would be useful to see the warnings that may come from our code, for example.

```{r}

# Check how many we're about to bring back
do(sum(grepl("REMAND", appeals)))

# Bring them back from the workers
remand <- do(appeals[grepl("REMAND", appeals)])

length(remand)

```

In summary, when working with larger data sets it's efficient to minimize
the data movement. We avoided it in this case by only distributing the
relatively small vector of file names and having each worker independently
load the files that it needed, thus keeping the data in place on that
worker.

```{R}

stop_cluster(do)

```

# Script

Parallelism is useful if it improves the speed of a slow program. If speed
doesn't improve then parallelism is an unnecessary complication.
`autoparallel` transforms programs from serial into multicore parallel, and
then benchmarks the modified program to determine if the transformation
increases the speed.

The word 'program' means a collection of valid R statements. Typically this
means a script or a function.

## Basic Transformations

We begin with the simplest and most obvious way to transform a program.
Top level occurences of `lapply, mapply, Map` are changed to `mclapply,
mcmapply, mcMap` from the `parallel` package, and the run times are
compared.  Below `lapply, mapply, Map` are referred to as the 'target
statements'.

This technique may be useful if the following conditions are met:

- System supports fork based parallelism (not Windows)
- Program spends a large amount of time in the target statements
- Program will be ran many times (benchmark requires program to run)
- Repeated evaluation of the target statements doesn't change output or
  have otherwise adverse effects, ie. repeatedly writing data to places it
  should not.

Consider the following simple program:

```{R}

# simple.R

ffast = function(x) rnorm(1)

fslow = function(x){
    Sys.sleep(0.1)
    rnorm(1)
}

z = 1:10
r1 = lapply(z, ffast)
r2 = lapply(z, fslow)

```

To make this run faster the last line should be changed to:

```{R}

r2 = parallel::mclapply(x, fslow)

```

To transform it:

```{R}

library(autoparallel)

benchmark_transform("simple.R", output = "simple2.R")

```

------------------------------------------------------------


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
