Thu Feb 22 09:06:00 PST 2018

Had a rough night with the 2 year old last night, so these thoughts might be a
little scattered.

High level question:

What features make R code more or less easy to analyze?

Consider SQL as an example of a declarative language operating on
tables.

## SQL Example

I would like to treat the code as orthogonal to the data to which it is
applied. This is what SQL
does. SQL is declarative, it describes what to do. To actually execute the
query a database must parse the SQL and compile it into physical operators that run
in that database. SQL generally separates the data loading steps from the query.
If data has the same structure, ie. the same DDL giving rise to the same
columns and types, then the same query should run on different databases.

Some attractive features of SQL:

- Queries don't utilize physical structure of data (although indexes do,
  but this doesn't change the semantics of the query, just the performance.)
- Simple set of data structures, ie. the only objects are tables consisting
  of columns with basic types.
- Tables are closed under queries, every query produces another table.
- Relational algebra provides a sound theoretical basis.

We can evaluate a domain specific language (DSL) like SQL using several criteria:

- Clarity and elegance of the conceptual model of the language
- How easily the DSL expresses the common tasks it was designed for
- Flexibility to express more complex tasks from within the DSL
- Ability for a system to map (or compile) the DSL into efficient physical
  instructions


## R data frame

If I restrict the scope of code analysis to data frames then there are 3
popular ways to do this:

- base R
- data.table
- dplyr

They are not mutually exclusive, ie one might mix two of them. We can refer
to these as DSL's because they all offer distinct syntax to perform
operations that are similar to SQL type queries on tables. They go beyond
SQL since they support general R functions. I'm thinking about doing some
sort of global script optimization for code written using these packages.

I'm interested in these DSL's for the purpose of code analysis and
code transformations. So I want to start with the
one that's easiest to analyze. If we restrict ourselves to the class of
operations on tables that they all do well and easily then it may be
possible to convert all of them to and from a common intermediate
representation that captures the desired semantics. We could even go beyond
the R language into say Python pandas and SQL.

Here's a simple example of the syntax using an example borrowed from the
[dplyr
documentation](https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html):


### base R

Base R lets us build a logical vector to filter the rows in a couple different ways.

```{R}

library(nycflights13)

flights_df = as.data.frame(flights)

month_var = "month"
day_var = "day"

# standard evaluation:
condition = flights_df[, month_var] == 1 & flights_df[, day_var] == 1

# NSE in `$`
condition = flights_df$month == 1 & flights_df$day == 1

# NSE using `with` to scope inside the data frame
condition = with(flights_df, month == 1 & day == 1)

```

Once we have the logical vector for the filter we can use it directly, or
we can use nonstandard evaluation in subset.

```{R}

# standard evaluation
f11 = flights_df[condition, ]

# NSE includes column names in scope
f11 = subset(flights_df, month == 1 & day == 1)

```

## data.table

data.table is similar to base R.
It will use standard evaluation in the special case when there is a
single symbol in the first argument.

```{R}

library(data.table)
flights_dt = data.table(flights)

# standard evaluation
f11 = flights_dt[condition, ]

# NSE includes column names in scope
f11 = flights_dt[month == 1 & day == 1, ]

```

## dplyr

The use c

```{R}

library(dplyr)
library(rlang)
flights_tbl = flights

# standard evaluation
f11 = filter(flights_tbl, condition)

# NSE includes column names in scope
f11 = filter(flights_tbl, month == 1 & day == 1)

# NSE includes column names in scope and using `&` on args
f11 = filter(flights_tbl, month == 1, day == 1)

# NSE explicitly scoping inside flights_tbl
f11 = filter(flights_tbl, .data$month == 1, .data$day == 1)

# tidyeval framework with quoting
# https://stackoverflow.com/questions/24569154/use-variable-names-in-functions-of-dplyr
month_quo = quo(month)
day_quo = quo(day)
f11 = filter(flights_tbl, (!!month_quo) == 1, (!!day_quo) == 1)

# tidyeval framework with a string
month_quo = new_quosure(as.symbol(month_var))
day_quo = new_quosure(as.symbol(day_var))
f11 = filter(flights_tbl, (!!month_quo) == 1, (!!day_quo) == 1)

```

dplyr also has a deprecated form of standard evaluation, which basically
takes a string and does nonstandard evaluation with it:

```{R}
f11 = filter_(flights_tbl, "month == 1 & day == 1")
```


dplyr has other variations in how to program
http://dplyr.tidyverse.org/articles/programming.html


## Extra

Not sure where to put this in the narrative

Some of the dplyr stuff maps R to SQL

Of these three I would say base R provides the most flexibility, since we
can do anything in the R language.

[rquery](https://winvector.github.io/rquery/) is a promising new package
distinguished in being designed to support some query optimizations, but it
doesn't have the popularity of the others.

Base R uses nonstandard evaluation (NSE) in `subset`
data.table and dplyr use NSE extensively.

There is code in base R, ie. the methods for the `data.frame` class.

Matt Dowle released __data.table__ on CRAN in 2006. The core syntax is
`DT[i, j, by]`. It

Hadley Wickham released __dplyr__ on CRAN in 2014. 



## High level Questions / Tasks

__Cloud Computing__

If we pay for computation and storage then we can do things based on cost.
We have access to a potentially limitless amount of computing power.
Things we might like to do when evaluating a particular piece of code on a
particular data set:

- Minimize cost
- Minimize time
- Minimize cost such that the computation takes no more than `h` hours
- Minimize time such that the computation costs no more than `d` dollars

Mon Feb 26 13:25:22 PST 2018

Following meeting with Duncan on Friday I'm writing down questions to
answer with code analysis.

Duncan's use case: people come him with code to make faster. They often
give him the whole data set which may take days to run. It would be neat to
look at the code and then artificially create a data set that is similar to
the large one. This must be similar to generated tests that aim to explore
every branch.

## Outcomes

What are my high level goals?

__Speed__

Take code that runs in 20 minutes and make it run in 10 minutes. There are
many ways to do this: detecting programming mistakes, compilation,
parallelism, dropping in more efficient implementations, etc.

__Memory__

Take code that requires 5 GB, and run it in a way that requires only 2 GB,
or even just 10 MB. This may be possible with streaming computations.

__Data Abstraction__

Take code that runs on a local data frame and evaluate it efficiently on
any tabular data source. The data could be a table in a database, a bunch
of files in a local directory, or a file on Amazon's S3.




## More Technical

What else do I want from the R code analysis? 

What kind of data frame will a function call generate? Column 
