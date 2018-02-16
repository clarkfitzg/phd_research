Fri Feb 16 09:15:45 PST 2018

# Milestones

The central idea of my thesis is to be able to take information on (code,
data, platform) and describing or possibly producing a strategy to execute
it, with a focus on acceleration through parallelism. 

In the interest of making progress on my thesis this is a list of potential
milestones.  Each one should be take around 1 month to complete.

## 1 Examine large corpus of code

For this milestone I would systematically examine a more extensive corpus
of R code to detect and quantify empirical patterns in how programmers use
various idioms and language features that are or are not amenable to
parallelization.

If we can show that some fraction of the code can potentially benefit from
a particular code analysis / transformation then this demonstrates
relevance.

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

__task parallelism__ This means representing the statements of the code,
say a function body or a script, as a directed acyclic graph based on the
implied dependencies. For a more complete description see my [writeup on
expression
graphs](https://github.com/clarkfitzg/phd_research/blob/master/expression_graph/expression_graph.tex).
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
[Example
vignette](https://www.bioconductor.org/packages/release/bioc/vignettes/apComplex/inst/doc/apComplex.R)
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


## 2 Data Description

Precisely define what a data description consists of, which I'll
focus on, and how they can be extended. This makes the starting point of
my research much more concrete.

Files and databases seem like the most commonly used sources of data in my
experience. I've already looked at these in the sense of Hive databases and
flat text files.


## 2 Parallel data structure for code

Represent R code in a data structure that exposes the ideal parallelism
in terms of both data and task parallelism. The task parallelism and the
data flows come through the expression graph.

This milestone would be greatly simplified if I narrow down and focus on a
subset of the language. For example, I should probably be sticking to pure
functions.

