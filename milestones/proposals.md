Fri Feb 16 09:15:45 PST 2018

# Milestones

The central idea of my thesis is to be able to take information on (code,
data, platform) and describe or produce a strategy to execute it, with a
focus on acceleration through parallelism. 

In the interest of making progress on my thesis this is a list of potential
milestones.  Each one should be take around 1 month to complete.


## 1. Parallel data structure for code

__Outcome__:
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
   a fancier version of R's AST.

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
to know in the AAST: classes, object sizes, timings for
each function and method call, etc. It doesn't seem unreasonable to require
one run. If the user hasn't run the program once then how do they know that
it's slow?  The other standard advice for slow code is to profile it, which
again requires running it.

The AAST should support
"optimization passes", ie. to eliminate unnecessary code or to
transform a `for` loop into an `lapply` as described in the Code Analysis
project Nick, Duncan, Matt and I worked on in the fall of 2017.

This milestone might be might simplified if I narrow down and focus on a
subset of the language. For example, if I'm thinking about pushing it into
SQL then I should be thinking about the 52 methods for data frames.

I need to clearly specify the set of optimizations / code transformations
under consideration, and then design the data structure with this
in mind. This set should also be extensible, ie. we can add more
transformations later. Possible transformations include:

- removal of unnecessary code
- replacement of duplicated code with a variable
- rewrite vectorized code as `lapply`
- run `lapply()` in parallel
- stream through chunks of the data
- pipeline parallelism, related to streaming chunks
- chunk data at the source so we can run in parallel
- task parallelism
- push some operations from the R code into an underlying SQL database, or
  some other preprocessor ie. `pipe(cut -d , -f 1,2 big_file.csv)`

The Hive idea essentially does the last one- it pushes the column selection
into the DB query and reorganizes the data so that it can be run with
streaming chunks.


## 2. Data Description

__Outcome__: _Precise definition of what a data description consists
of, which data sources I'll focus on, and how they can be extended._

This will make the starting point of my research much more concrete.
I currently have in mind the vague idea that relevant statistics related to
the data description are available because they have been computed ahead of
time.

### Prerequisites

Analyzing a corpus of R code would help justify the data sources that I
choose to focus on. It would also show me the dominant patterns in data
access, ie. how do people actually iterate through database cursors?
How much R code is focused on data frames and how much is focused on
matrices? How do the programs use the structure in their data, and what can
be prepared ahead of time?

On the other hand, a corpus of open source R code is a biased sample,
because private code is probably much more likely to access private data
warehouses.

### Description

I'm most interested in tabular data from flat text files and databases,
because these are the most common large sources of data that I've seen. To
analyze tabular data an R script typically begins by reading all the data
into a data frame in memory. This code to read it in is essentially an
implementation detail that can range from simple loading of a serialized R
object in a local file to complex stream processing of a database. For
large data sets this code can impact performance by orders of magnitude. To
what extent can we automate the generation of this code?

Let's consider column selection as a potential use case. The following
naive code selects the first two columns:

```{R}
x = read.csv("x.csv")
x = x[, 1:2]
```

A more sophisticated approach uses pipeline parallelism to select the
columns from within a shell preprocessing step:

```{R}
x = read.csv(pipe("cut -d , -f 1,2 x.csv"))
```

It's not too difficult to analyze the naive version to determine the
desired semantics: "save the first two columns of the table `x.csv` into a
data frame called `x`". I've done this type of column use inference. Once
we know this we could generate the sophisticated version. If we start with
the sophisticated version these semantics are much more difficult to
statically infer, because we need to parse and understand the shell
command. In general a shell command could call any program and do anything.

The case with SQL queries is similar. If we know the target semantics then
we can generate basic SQL, but if we start with SQL then we need the
ability to parse and semantically analyze the SQL. This is a
complex task.

I would prefer to separate the code that initially loads the external data
from the remainder of the script. We can replace this code with more
efficient code given knowledge of the data. For example, we might use the
`pipe("cut...` approach above if we know:

- `x.csv` has 10 million rows, 100 columns
- We're running on a POSIX system that has `cut`.
- There are no factor or character columns, so string escaping and newlines
  won't cause `cut` to fail.
- We can't use `data.table::fread("x.csv", select = 1:2)` because it's
  not installed.

For tables we would like to know:

- __dimensions__ the number of rows and columns. Then we can potentially
  determine whether there will be memory issues.
- __data types__ boolean, float, character, etc. Specifying this avoids
  inference errors and speeds up `read.table`.
- __sorted__ is the data sorted on a column? This allows
   streaming computations based on groups of this column.
- __index__ does data come from a database with an index?
   Then data elements can be efficiently acccessed by index.

One general form of data is just text coming through UNIX `stdin`. This
equates to a `read.table()` or `scan()`. It's the same interface that Hive
uses.

More generally for large data sets we would like to know physical
characteristics of the system delivering the data:

- __IO throughput__ How many MB/sec can the source deliver the data?
- __IO latency__ How long does it take after a request before the source
  begins to deliver the data?
- __Splittable__ Can the source provide the data split up in chunks?
- __Parallel__ Can we give multiple parallel read requests?


A related aspect I've been particularly
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

Jan Vitek's group has done quite a bit of work in this area, and hopefully
I can build on this.

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

