## Filtering at the source

The idea I have in mind here is an analyst writing ad hoc R code that
applies to tables in a large external data set. They might initially
develop the code by first loading a manageable sample of the data into R.
Then they would like to apply the same code to a data set that won't fit
into memory. This won't work without modifying their code.

The general task is to have a system examine their code and find out some
way to make it work.

The specific task I'm considering here is examining the code to discover if
the computation can be separated into an initial row / column filter on one
or more data frames followed by computations in R. Then we can arrange to
filter the data frames before loading the data into R.


## Hypothetical Example

Here's some hypothetical code that Duncan and I were talking about:

```{R}
x = subset(table_1, a < 10, select = c("a", "b"))
y = subset(table_2, (a == 5 & !is.na(b)) | (a == 6 & d < abs(f)))
xy = merge(x, y)

# Goal of the computation:
model = lm(b ~ d, xy)
```

We are free to run the first block of code in an alternative way provided
that it produces the same data frame `xy` with columns `b` and `d`.

If `table_1` and `table_2` are files then we can potentially stream the
`subset()` operations, and thus stay within memory. If these tables are
coming from a database then we can potentially run both the `subset()` and
the `merge()` within the databse.


### Specifying the tables

Before we can analyze the code we must specify a set of names corresponding
to tables that the code operates on. They appear as variable names in the
code. When reading the code we should consider them to be data frames that
exist in R's global workspace. We'll have to come up with a way to specify
this table name space, but one could imagine any of the
following:

- Explicitly listing all table names
- Specifying a pattern for the variable names to begin with, ie. `table_`
  as in the examples in this document
- The names of all CSV files in a particular directory
- All tables and views defined in a particular database schema

Ideally we know more than just the table name. We should also know the
dimensions, column names, and column types. 

The whole idea here is that we would like to generate more efficient code
to load the data based on what we can infer using the code. Thus we would
prefer to start with code that just uses these tables as if they were
loaded. Alternatively, if we start with the code that loads the tables, ie.
`read.csv("table1.csv", col.names = ..., colClasses = ...)` then we can
potentially use this information in lieu of an external data description.


### Specifying the result

What's the purpose of the computation? It could be to make a plot, fit a
model, compute a table of summary statistics, etc. In the same way that we
needed to specify the tables in the external data source we need to specify
what this end goal is. For convenience here, suppose the goal is just to
execute the last line of code.


### Code Analysis

In the simplest case there is only one line of code, for example:

```{R}
model = lm(y ~ x1 + x2, table_1)
```

Our goal is to produce `table_1` containing only the subset of data that is
strictly necessary, namely columns `y, x1, x2`. What are the steps to
inferring this?

- Check for the existence of the global variable `table_1`.
- ?? Check if `table_1` is directly being filtered?

Actually might be useful here to use Nick's idea of "flattening" the code,
since then I don't have to deal with nesting.


### Ryan's example

Today (12 Mar 18) Ryan Peek showed me a use case for source filtering
on genomic data. His analysis consists of the following steps:

- read in a 155K x 1141 flat text file of sequencing data
- transform it using dplyr (mostly column selection, renaming)
- joins along with some other metadata
- produce a much smaller table for plotting, ie. 700 x 2 or something like
  that

One difficult part in the transformation is pivoting the table from wide to
long.

After reading in the raw text data he saves it in a binary format using the
fst package so that it will be faster to load for subsequent iterative
development.

One reason his use case is interesting is because the size of the data
pushes R near the edge of what it can handle in memory. Then he has to
switch to a completely different approach once it exceeds memory.



### Scratch

Fri Mar  9 15:13:15 PST 2018

This is the R code expressing the PEMS analysis. It does the following:

- Select three columns from the `pems` table.
- Split it on the `station` column.
- Apply the function `npbin` to each group.

```{R}
fd_shape = by(data = pems[, c("station", "flow2", "occupancy2")]
              , INDICES = pems2[, "station"]
              , FUN = npbin
              )
```

A programmer can look at the code and see that 
the `subset` commands filter the data. 

Some portion of this code can run in a database. For example, the basic
subset to create `x`. The more complex code to create `y` 

Related idea: data virtualization.

Idea: list different ways to integrate data from two sources in one R computation.

Idea: row / column filters in iotools

