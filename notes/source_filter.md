## Filtering at the source

Intro

### Specifying the tables

Before we can analyze the code we must specify a set of names corresponding
to tables that the code operates on. They appear as variable names in the
code. When reading the code we should consider them to be data frames that
exist in R's global workspace. We'll have to come up with a way to specify
this table name space, but one could imagine any of the
following:

- Explicitly listing all table names
- Specifying a pattern for the strings to begin with, ie. `_external_`
- All CSV files in a particular directory
- All tables and views defined in a particular database schema

Ideally we know more than just the table name. We should also know the
dimensions, column names, and column types. 

The whole idea here is that we would like to generate more efficient code
to load the data based on what we can infer using the code. Thus we would
prefer to start with code that just uses these tables as if they were
loaded. Alternatively, if we start with the code that loads the tables, ie.
`read.csv("table1.csv", col.names = ..., colClasses = ...)` then we can
potentially use this information in lieu of an external data description.

### Code analysis

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

Here's some hypothetical code that Duncan and I were talking about:


```{R}
x = subset(table1, a < 10, select = c("a", "b"))

y = subset(table2, (a == 5 & !is.na(b)) | (a == 6 & d < sin(f)))

xy = merge(x, y)

model = lm(b ~ d, xy)
```

A programmer can look at the code and see that 
the `subset` commands filter the data. 

Some portion of this code can run in a database. For example, the basic
subset to create `x`. The more complex code to create `y` 

Related idea: data virtualization.

Idea: list different ways to integrate data from two sources in one R computation.
