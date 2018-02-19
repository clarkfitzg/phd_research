Fri Feb 16 09:15:45 PST 2018

# Milestones

The central idea of my thesis is to be able to take information on (code,
data, platform) and describe or produce a strategy to execute it, with a
focus on acceleration through parallelism. 

In the interest of making progress on my thesis this is a list of potential
milestones.  Each one should be take around 1 month to complete.


## 1. Parallel data structure for code

Represent R code in a data structure that exposes the ideal parallelism in
terms of both data and task parallelism. The data structure should capture
the semantics of the input R code. We should be able to make round trip
transformations: input R code -> parallel data structure -> output R code.
It's not necessary that input and output R code match. Indeed, the purpose
of the data structure is to change the output R code to make it more
efficient in some way.

This would be a useful conceptual tool because it shows all possible ways
to make high level code parallel. We can think of it as an intermediate
representation of the code.

Requirements listed in order of priority:
1. Robust- Read any R code without parsing errors, and also write it out.
1. Task graph- Capable of representing statement dependencies, ie.
   statement 9 depends on the result of statement 5.
1. Extensible- can add extra information, ie. timings, classes and sizes of
   objects
1. Extensible- supports optimization passes

Non-requirements:
1. Control flow- I'm happy to leave loops as single nodes representing
   function calls. They can be modified in optimization passes if
   necessary.

### Prerequisites

This can potentially build on the following existing work:
- __rstatic__ provides type inference and data flow information through SSA .
- __CodeDepends__ makes it easy to grab the functions that I'm looking for
  through the function handlers, but I've also written my own code to do
  this.
- __expression graph__ that [I worked on
  previously](https://github.com/clarkfitzg/phd_research/blob/master/expression_graph/expression_graph.tex)
show the task parallelism.

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

For this milestone I'll define precisely what a data description consists
of, which I'll focus on, and how they can be extended. This makes the
starting point of my research much more concrete.

Files and databases seem like the most commonly used sources of data in my
experience. I've already looked at these in the sense of Hive databases and
flat text files.

One general form of data is just text coming through UNIX `stdin`. This
equates to a `read.table()` or `scan()`. It's the same interface that Hive
uses.

R Consortium has refined the DBI specification recently. That could provide
a starting point for thinking about data coming from a database. One way to
get parallelism is through multiple clients:
https://www.percona.com/blog/2014/01/07/increasing-slow-query-performance-with-parallel-query-execution/

## 2. Examine large corpus of code

For this milestone I would systematically examine a more extensive corpus
of R code to detect and quantify empirical patterns in how programmers use
various idioms and language features that are or are not amenable to
parallelization.
If we can show that some fraction of the code can potentially benefit from
a particular code analysis / transformation then this demonstrates
relevance.

### Prerequisites

The data structure for parallelism would be very useful, because it more
systematically describes the structure in the code that I'm looking for
compared to ad hoc methods like "grep".

### What to look for

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
  write a package
- Package code likely does more checking than typical data analysis code
- Compiled code is more likely to be here than anywhere else

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

