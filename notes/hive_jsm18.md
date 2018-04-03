Tue Mar 13 08:53:09 PDT 2018

The title for my JSM talk is "Automatic Parallelization of R Code" in the
section "Statistical Computing on Parallel Architectures". Norm is
completely open to me talking about whatever I find interesting. Even
challenges or "this is what we should do".

What key points do I want to convey in the talk?

- For seriously large data and computations we should try to leverage
  and integrate with existing technologies rather than reinventing them.
- We can use R code as the input to directly generate code that integrates with
  a larger system.

## PEMS as example

I plan on talking about the PEMS analysis. So I should at least fully
describe that use case in terms of the automatic parallelization. When I
was working on this in the fall I stopped after the code generation in
`autoparallel::write_udaf_scripts` because I felt like anything further
would be too specific, ie make too many assumptions about the program.
To claim that we're "automatically" handling the parallelism based on the R
code I need to do more- analyze the code to generate and then call the
lower level `autoparallel::write_udaf_scripts`.

Suppose that we've created a view or table in Hive called `pems2`. It could
have come in through any of the following:

- It was already loaded in the database
- We wrote the SQL by hand
- dbplyr generated it from R

We would like to evaluate this code in Hive:

```{R}
fd_shape = by(data = pems2
              , INDICES = pems2[, "station"]
              , FUN = npbin
              )
```

I assume that we start with the code. We can query the schema of the
database to find out the column names and classes of `pems`.  Then the code
analysis needs to infer the following things:

- `cluster_by = "station"`
      Easy. Comes from analyzing `INDICES` argument to `by()`, could be multiple columns
- `input_table = "pems"`
      A free variable we're treating as a data frame
- `input_cols = c("station", "flow2", "occupancy2")`
      Column use inference, already have some tools to do that
- `output_table = "fd_shape"`
      The final assignment that we want to keep
- `output_cols = c("station", "right_end_occ", "mean_flow", "sd_flow", "number_observed")`
      From analyzing the return value of npbin
- `output_classes = c("integer", "numeric", "numeric", "numeric", "integer")`
      Need general type inference for this

SQL generation, type inference- we can do these things. They may not be
fully mature technologies in R, but they're not that far out either. If we
assume that we have these capabilities then what can we say? Then we don't
have to worry about generating the SQL for `pems[, c("station", "flow2",
"occupancy2")]`- it's a different problem. But it matters here, because
we're generating the SQL for the `CLUSTER BY`, so we have to at least be
able to compose the SQL at the right place.


## interface

The high level idea is to take R code and run it on data that's stored in
Hive. In this way we bring the code to the data and operate in place, which
is a big win. But how do we actually realize this goal? What's the right
interface?

How much does this generalize? What other classes of computations can we
handle with the same approach?

- group by: `new_table = by(hive_table, hive_table[, columns], FUN)`
- vectorized functions: `hive_table$ab = hive_table$a * hive_table$b`

And how do we know that funcs are vectorized? Vectorized funcs are closed
under composition. So maybe start with a base case of vectorized functions
in R and infer about it from there. This is pretty similar to the dimension
inference that Duncan, Nick and I were discussing.

I shouldn't be in the business of generating SQL, because it's
already commonly done, and hence not research. How do I delegate it to a
different package? We could let dplyr (or anything else) generate a view,
and then work off that. Can we infer columns and types for a view? Because
I need that to generate the code.

Speaking of views, we could allow every intermediate data frame variable in
an R script to be a view, and then execute just one final query allowing
whatever optimizations to happen.

Another possible angle to take so that this is not so limited is to say
that we can generate and analyze base R, data.table, or dplyr. But this
basically just amounts to syntactic sugar, and needing more code analysis
capabilities to deal with each different library using NSE.

Then probably I need a different example, for example multiprocessing with
shared memory to show how to generate a different type of code.
So I can write something like `parallel_by` that works in memory in the
conventional way. Then how do we decide to use the parallel version? We're
probably back to the `parallelize.dynamic` approach in @bohringer2013dynamic.

If the table has already been split to the right groups on disk then
multiprocessing for parallelism makes sense. We can still limit the memory
footprint.

At this point I'm thinking all I can really do with Hive is the call to
`by()`. It feels like just a clever interface, not much more.
For this to be richer I need to be operating on whole scripts.


## dplyr

dplyr can do a fair amount of this. It lazily builds up SQL queries and
fires them off when they're needed. Then the database is free to optimize
the SQL as it chooses. To execute the above code it needs to
call `do()` to execute arbitrary R code, and so brings all the data back
into the managing R session. This model doesn't work if the data won't fit
in the R session.

Can I leverage [dbplyr](http://dbplyr.tidyverse.org/articles/dbplyr.html)
to generate the SQL? Let me try:

```{R}

library(dplyr)
library(dbplyr)
con <- DBI::dbConnect(RSQLite::SQLite(), path = ":memory:")

n = 10
local_pems = data.frame(station = rep(1:3, length.out = n)
    , flow2 = rnorm(n), occupancy2 = rnorm(n))

copy_to(con, local_pems, "pems", temporary = FALSE)

pems = tbl(con, "pems")

pems2 = select(pems, station, flow2, occupancy2)
groups = group_by(pems2, station)

# column selection is fine
show_query(groups)

fd_shape = do(groups, head(., 2))

# Doesn't work, presumably because the `do()` causes it to actually be computed
# show_query(fd_shape)
```

Suppose we use common aggregation functions:

```{R}
agg = summarize(groups, max_flow = max(flow2, na.rm = TRUE)
    , mean_occ = mean(occupancy2, na.rm = TRUE))
```

The SQL dbplyr generates looks reasonable:

```
> show_query(agg)
<SQL>
SELECT `station`, MAX(`flow2`) AS `max_flow`, AVG(`occupancy2`) AS
`mean_occ`
FROM (SELECT `station`, `flow2`, `occupancy2`
FROM `pems`)
GROUP BY `station`
```

What happens when we aggregate with a user defined function?


```{R}
udf_max = function(x) max(x, na.rm = TRUE)
agg2 = summarize(groups, max_flow = udf_max(flow2)
    , mean_occ = mean(occupancy2, na.rm = TRUE))
```

The generated SQL then assumes that `UDF_MAX` is a function available
inside the database. Then of course fails when it's not present. This
default forces the computation on the group to happen inside the database.

```
> show_query(agg2)
<SQL>
SELECT `station`, UDF_MAX(`flow2`) AS `max_flow`, AVG(`occupancy2`) AS
`mean_occ`
FROM (SELECT `station`, `flow2`, `occupancy2`
FROM `pems`)
GROUP BY `station`
>
> agg2
Error in rsqlite_send_query(conn@ptr, statement) :
  no such function: UDF_MAX
```

Reading through [dbplyr's SQL
generation](http://dbplyr.tidyverse.org/articles/sql-translation.html#behind-the-scenes).
I've considered using something like Apache Calcite for an intermediate
semantic representation. Does dbplyr do this, or is it a direct translation
from R to SQL? The docs indicate that dbplyr creates an intermediate
representation building on `tbl_lazy`.

Is it worth it for me to build on this?

## Bigger picture

What's the motivation for all this? R's iterative development style is
productive and nice. But in the end we may want to run the code on a bigger
data set, or make it fast somehow. I would like to argue that we need to
leverage query optimization techniques if all we're doing is computing on
data frames. But the PEMS one doesn't _need_ any query optimization because
it's so simple. Hmmm.

There are some very similar popular technologies out there:
- lazy compute graph as in dask
- data flow as in tensorflow
- enqueuing operations into a GPU
- RSlurm package generating code that can run on SLURM

How is what I'm proposing different? All of the above require one to
program according to some specific model.
dplyr also requires programming according to a specific model, but then
generates code that can run on databases as well as data frames in memory.



## Scratch

We should note that this technology isn't specific to Hive. MS SQL server has
similar capabilities:
https://docs.microsoft.com/en-us/sql/advanced-analytics/r/how-to-create-a-stored-procedure-using-sqlrutils.
