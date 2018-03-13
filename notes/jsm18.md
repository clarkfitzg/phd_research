Tue Mar 13 08:53:09 PDT 2018

The title for my JSM talk is "Automatic Parallelization of R Code" in the
section "Statistical Computing on Parallel Architectures". Norm is
completely open to me talking about whatever I find interesting. Even
challenges or "this is what we should do".


## PEMS as example

I plan on talking about the PEMS analysis. So I should at least fully
describe that use case in terms of the automatic parallelization.
I didn't want to generate the SQL before because it seemed too
specific. 

```{R}
fd_shape = by(data = pems[, c("station", "flow2", "occupancy2")]
              , INDICES = pems[, "station"]
              , FUN = npbin
              )
```

The code above has the following characteristics: 

- selects columns from table in the database
- groups by one or more of these column
- apply an R function that produces a data frame

I assume that we start with the the code. We can query the schema of the
database to find out the column names and classes of `pems`.  Then the code
analysis needs to infer the following things:

- `cluster_by = "station"`
      Comes from analyzing by(), could be multiple columns
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

# Doesn't work, because it's computed
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



## Scratch

We should note that this technology isn't specific to Hive. MS SQL server has
similar capabilities:
https://docs.microsoft.com/en-us/sql/advanced-analytics/r/how-to-create-a-stored-procedure-using-sqlrutils.
