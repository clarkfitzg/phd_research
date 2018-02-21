Fri Feb 16 09:15:45 PST 2018

# Milestones

The central idea of my thesis is to be able to take information on (code,
data, platform) and describe or produce a strategy to execute it, with a
focus on acceleration through parallelism. 

In the interest of making progress on my thesis this is a list of potential
milestones.  Each one should be take around 1 month to complete.


## 1. Parallel data structure for code

__Outcome__ 
_Represent R code in a data structure that exposes high level parallelism_

We can think of this as an augmented abstract syntax tree (AST), so I'll
refer to it here as the AAST.

__Potential uses:__ 
1. Detect and quantify possible levels of parallelism in large corpus of R
   code.
1. Optimization passes at the R language level, ie. transforming a
   `for` loop into an `lapply()`.
2. Generate parallel code from serial.

The AAST should capture the semantics of the input R code. We should be
able to make round trip transformations: input R code -> AAST -> output R
code. It's not necessary that input and output R code match, but they must
produce the same results, ie. the same plots or the same output files.

This would be a useful conceptual tool because it shows direct ways
to make high level code parallel. Low level methods include replacing
individual functions or BLAS with parallel implementations. The focus is
not on this low level parallelism.

__Requirements__ in order of priority:
1. Robust- Read any R code without parsing errors, and also write it out.
1. Task graph- Capable of representing statement dependencies, ie.
   statement 9 uses variable `x` which was defined in statement 5.
1. Extensible- possible to add extra information, ie. timings, classes and sizes of
   objects

__Non-requirements:__
1. Control flow- I'm happy to leave loops as single nodes representing
   function calls. They can be modified in optimization passes if
   necessary.
2. Language independence- The goal is not to reinvent
   [LLVM](https://llvm.org/docs/LangRef.html#abstract). This is just
   a fancier version of the R AST.

### Prerequisites

This can build on the _expression graph_ that [I worked on
previously.](https://github.com/clarkfitzg/phd_research/blob/master/expression_graph/expression_graph.tex)
`CodeDepends` provides the basic static analysis functionality.

`rstatic` seems less suited to the basic requirements above, since it's
designed for lower level tasks related to compilation. The SSA information is
appealing though.

### Description

Static analysis of the code by itself can't _actually_ show if parallel
will be more efficient, because we don't know how large the data is and how
long anything will take to run.  What I would really like is some kind of
class and dimension inference, but this seems like wishful thinking.

If we run the code once then we can "fill in" everything that we would like
to know in the parallel data structure: classes, object sizes, timings for
each function and method call, etc. It doesn't seem unreasonable to require
one run; if the user hasn't run it then how do they know that it's slow?
The other standard advice for slow code is to profile it, which again
requires running it.

This data structure should be extensible in the sense that we can make
"optimization passes" on it, ie. to eliminate unnecessary code or to
transform a `for` loop into an `lapply` as described in the Code Analysis
project Nick, Duncan, Matt and I worked on in the fall of 2017.

This milestone might be might simplified if I narrow down and focus on a
subset of the language. For example, I should probably be sticking to pure
functions. If I'm thinking about pushing it into SQL then I should probably
be focusing on methods for data frames. There aren't too many of them:

```
> methods(class = "data.frame")
 [1] [             [[            [[<-          [<-           $
 [6] $<-           aggregate     anyDuplicated as.data.frame as.list
[11] as.matrix     by            cbind         coerce        dim
[16] dimnames      dimnames<-    droplevels    duplicated    edit
[21] format        formula       head          initialize    is.na
[26] Math          merge         na.exclude    na.omit       Ops
[31] plot          print         prompt        rbind         row.names
[36] row.names<-   rowsum        show          slotsFromS3   split
[41] split<-       stack         str           subset        summary
[46] Summary       t             tail          transform     unique
[51] unstack       within
```

I need to clearly specify the set of optimizations / code transformations
under consideration, and then design the data structure with this
in mind. This set should also be extensible, ie. we can add more
transformations later. Possible transformations include:

- rewrite vectorized code as `lapply`
- run `lapply()` in parallel
- stream through chunks of the data
- pipeline parallelism, related to streaming chunks
- chunk data at the source so we can run in parallel
- task parallelism
- push some operations from the R code into an underlying SQL database

The Hive idea essentially does the last one- it pushes the column selection
into the DB query and reorganizes the data so that it can be run with
streaming chunks.

One idea that might be too specific is detecting several iterated
vectorized function calls followed by a reduce, ie. `sum(f(g(h(x))))`.


## 2. Data Description

__Outcome__ _Precise definition of what a data description consists
of, which data sources I'll focus on, and how they can be extended._

This will make the starting point of my research much more concrete.
I currently have in mind the vague idea that every interesting statistic
related to the data description has been computed and is available ahead of
time.

### Prerequisites

Analyzing a corpus of R code would help justify the data sources that I
choose to focus on. It would also show me the dominant patterns in data
access, ie. how many people actually iterate through a database cursor?
How much R code is focused on data frames and how much is focused on
matrices? How do the programs use the structure in their data, and what can
be prepared ahead of time?

On the other hand, a corpus of open source R code is a biased sample,
because private code is probably much more likely to access private data
warehouses.

### Description

For parallel programming on large data sets we would like to know physical
characteristics of the system:

- __IO throughput__ How many MB/sec can the source deliver the data?
- __IO latency__ How long does it take before the source begins to deliver
  the data?
- __Splittable__ Can the source provide the data split up in chunks?
- __Parallel__ Does the support multiple parallel read requests?


Flat files and databases seem like the most commonly used sources of large
tabular data in my experience. I've already looked at these in the sense of
Hive databases and flat text files. For tabular data, we would like to
know:

- __dimensions__ the number of rows and columns. Then we can determine
   whether there will be obvious memory issues and preallocate arrays.
- __data types__ boolean, float, character, etc. Specifying this avoids errors
   that can rise when inferring from text.
- __factor levels__ possible values for categorical data.
   Then we can preserve this information even if one value is rare and
   doesn't always appear in the data.
- __randomization__ has the data already been intentionally randomized?
   If it's random then we can easily statistically sample by reading
   the first rows.
- __sorted__ is the data sorted on a column? This allows
   streaming computations based on groups of this column.
- __layout__ are multiple files used? If each file stores
   data corresponding to some unit, ie. one file per day and we do a
   computation for each day then parallelization is natural across
   files.
- __index__ does data come from a database with an index?
   Then data elements can be efficiently acccessed by index.
- __offsets__ knowing a numeric array with `n` rows and `p`
   columns is stored in column major order potentially allows more
   efficient reads of subsets of the data.

One general form of data is just text coming through UNIX `stdin`. This
equates to a `read.table()` or `scan()`. It's the same interface that Hive
uses.

R Consortium has refined the DBI specification recently. That could provide
a starting point for thinking about data coming from a database. One way to
get parallelism is through multiple clients:
https://www.percona.com/blog/2014/01/07/increasing-slow-query-performance-with-parallel-query-execution/

In my experience most data analysis R code reads all the data into memory,
and then computes on it.  One related thing I've been particularly
interested in is taking R code that assumes data will fit into memory, and
then modifying it to process data that won't fit into memory.

## 3. Examine large corpus of code

__Outcome__: _Quantify empirical patterns in how programmers use various
idioms and language features that are more or less amenable to
parallelization_

If we can show that some fraction of the code can
potentially benefit from a particular code analysis / transformation then
this demonstrates relevance.

### Prerequisites

Jan Vitek's group has done quite a bit of work in this area, and I may be
able to borrow all or part of their corpus.

The data structure for parallelism would be very useful, because it more
systematically describes the structure in the code
compared to ad hoc methods like `grep`.

### Description

We would look for usage of the following functions:

__apply functions__ This is the set of functions in base R that can be readily
parallelized. It includes `apply, lapply, sapply, tapply, vapply,
rapply, mapply, Map, eapply`. We also would like to know which functions are being
called, and if they have side effects that prevent them from running in
parallel. Examples of side effects we would like to capture include:

- using `<<-` or `assign()`
- appending to a file
- reference classes (requires knowing the class of objects- maybe difficult)
- manipulating environments (need to know class)

CodeDepends captures side effects, so hopefully we can integrate and build
upon it.

__split apply functions__ are also interesting, ie. `split, by, aggregate`.
It may be possible to split the data at the source and then compute on it
in parallel. For example, we can break a large file into many separate
files.

__task parallelism__ This means representing the statements of the code,
say a function body or a script, as a directed acyclic graph based on the
implied dependencies. 

For this task I need to characterize the expression graph based on the
potential theoretical parallelism. There are two extreme cases:

    - Every statement depends on the previous one so no parallelism is possible
    - Every statement is independent so we get an n fold speedup

Most should be somewhere in the middle.

### Where to look

__CRAN__ has about 10,000 packages. The code in the vignettes may have
realistic data analysis examples, but probably generally uses more literals
with toy / example data to avoid depending on external data sets.

- Typically code was written by more advanced users, ie. advanced enough to
  write a package.
- Package code likely does more condition checking than code used for data analysis.
- Compiled code is more likely to be here than anywhere else.

__Bioconductor__ has 1500 packages with easily accessible vignettes.
[(Example
vignette)](https://www.bioconductor.org/packages/release/bioc/vignettes/apComplex/inst/doc/apComplex.R)
Code will be pretty similar to CRAN, and some packages may well be on both.

__Github__ The Github search API provides at most 1,000 results per query. I
can potentially obtain more by designing queries that are mutually
exclusive. I could also just ask them to make an exception and give me the
full result set- I think there were about 15,000 repos matching some form of
the query "R data analysis".

- Users of all skill levels
- Data analysis repositories may offer a realistic view of how
  end users actually use packages and language features
- Git repos allow us to see how code has evolved over time
- Need to be careful about including homework assignments for various
  courses

