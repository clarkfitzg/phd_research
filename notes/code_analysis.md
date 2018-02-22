Thu Feb 22 09:06:00 PST 2018

Had a rough night with the 2 year old last night, so these thoughts might be a
little scattered.

High level question:
What features make R code more or less easy to analyze?


## SQL Example

I would like to treat the code as orthogonal to the data. This is what SQL
does. SQL is declarative, it describes what to do. To actually execute the
query a database must parse the SQL and compile it into physical operators that run
in that database. SQL generally separates the data loading steps from the query.

Some attractive features of SQL:

- Queries don't utilize physical structure of data (although indexes do,
  but this is really just for performance tuning).
- Simple set of data structures, ie. the only objects are tables consisting
  of columns with basic types.
- Tables are closed under queries, every query produces another table.
- Relational algebra provides a sound theoretical basis.

This generalizes beyond tables, for example we can compute on mathematical
algebraic structures using symbolic algebra.

We can evaluate a domain specific language (DSL) like SQL using several criteria:

- Clarity and elegance of the conceptual model of the language
- How easily the DSL expresses the common tasks it was designed for
- Flexibility to express more complex tasks using the DSL
- Ability for a system to map (or compile) the DSL into efficient physical
  instructions


## R data frame

Some of the dplyr stuff maps R to SQL

If I restrict the scope of code analysis to data frames then there are 3 DSL's:

- data.table
- dplyr
- [rquery](https://winvector.github.io/rquery/) (new package, but designed
  with this sort of optimization in mind)

I call them DSL's because they're all similar to SQL type queries on
tables. What I'm thinking about doing then is a sort of global script
optimization on these languages, which is sort of like PL/SQL.



Thu Feb 22 10:40:21 PST 2018

Forgot to push the commit, but mostly remember what I'm working on.

Computational Model
Domain
Ease of use
Flexibility
Compilation

Comparing three popular ways to write R code operating on data frames: Base
R's `data.frame`, `data.table`, and `dplyr`. These are all very popular
ways to do similar operations on tabular data. They go beyond SQL since
they allow us to use general R functions.

Of these three I would say base R provides the most flexibility, since we
can do anything in the R language.

However, I'm interested in these DSL's for the purpose of compilation
and code analysis. So I want to start with the one that's easiest to
analyze. If we restrict ourselves to the class of operations on tables that
they all do well and easily then it may be possible to convert all of them
to and from a common intermediate representation that captures the desired
semantics. We could even go beyond the R language into say Python pandas
and SQL.

Base R uses nonstandard evaluation (NSE) in `subset`
data.table and dplyr use NSE extensively.

There is code in base R, ie. the methods for the `data.frame` class.

Matt Dowle released __data.table__ on CRAN in 2006. The core syntax is
`DT[i, j, by]`. It

Hadley Wickham released __dplyr__ on CRAN in 2014. 

Here's a simple example of the syntax using an example borrowed from the
[dplyr
documentation](https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html):

```{R}

library(nycflights13)
library(data.table)
fd = data.table(flights)

# base R no NSE
f11 = flights[flights[, "month"] == 1 & flights[, "day"] == 1, ]

# base R using NSE in `$`
f11 = flights[flights$month == 1 & flights$day == 1, ]

# base R using NSE in `with`. A variation puts `with` on the outside
f11 = flights[with(flights, month == 1 & day == 1), ]

# base R using NSE in `subset`
f11 = subset(flights, month == 1 & day == 1)

# dplyr
f11 = dplyr::filter(flights, month == 1, day == 1)

# data.table
f11 = fd[month == 1 & day == 1, ]

```

