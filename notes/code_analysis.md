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

month_var = "month"
day_var = "day"

# standard evaluation:
condition = flights[, month_var] == 1 & flights[, day_var] == 1

# NSE in `$`
condition = flights$month == 1 & flights$day == 1

# NSE using `with` to scope inside the data frame
condition = with(flights, month == 1 & day == 1)

```

Once we have the logical vector for the filter we can use it directly, or
we can use nonstandard evaluation in subset.

```{R}

# standard evaluation
f11 = flights[condition, ]

# NSE in `subset`
f11 = subset(flights, month == 1 & day == 1)

```


## dplyr

```{R}

library(dplyr)
library(rlang)

# Doesn't work
f11 = filter(flights, !!condition)

# NSE implicitly scoping inside data frame
f11 = filter(flights, month == 1 & day == 1)

# NSE implicitly scoping inside data frame with implicit `&`
f11 = filter(flights, month == 1, day == 1)


# dplyr explicitly scoping inside flights
f11 = filter(flights, .data$month == 1, .data$day == 1)

# dplyr using tidyeval framework
# https://stackoverflow.com/questions/24569154/use-variable-names-in-functions-of-dplyr
month_quo = quo(month)
day_quo = quo(day)
f11 = filter(flights, (!!month_quo) == 1, (!!day_quo) == 1)

```


## data.table

data.table will use standard evaluation in the special case when there is a
single symbol in the first argument.

```{R}

library(data.table)
fd = data.table(flights)

# standard evaluation
f11 = fd[condition, ]

# NSE implicitly scoping inside data frame
f11 = fd[month == 1 & day == 1, ]

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


