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

