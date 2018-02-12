Thu Feb  8 15:34:19 PST 2018

After looking through these Github repos I've seen this merge pattern
repeated many times: `Reduce(merge, ...` to join more than 2 data frames.
And thinking about the work for the online company what I got out of the
database was the result of many joins. 

How (in) efficient is it to join tables like this?

Can we have something like a view in a SQL database where the actual data
frame is computed on the fly as needed? In the online work I couldn't do
the full join because the `items` table had 15 million rows and 30 columns
while the `products` table had 80 columns- it would have resulted in a data
frame with 15 million rows and 109 columns, too big for memory.

But I could do quite a lot with a _conceptual_ data frame of this size.
Some could even be files on disk.


## Background

I feel that statisticians have somewhat shied away from data
organization, especially the complex relationships found in relational
databases. But there may be something to be gained by using this model.

H. Wickham's tidy data idea is Codd's 3rd normal form. He shows how it
can lead to a more coherent view of computations on data. But it really
only focuses on one, sometimes two tables.

Wikipedia has some interesting [material on natural
joins](https://en.wikipedia.org/wiki/Join_(SQL)#Natural_join). They claim
natural joins are not practical in real world databases because there might
be thousands of tables so it's hard to even narrow down the column names.
Ie. many tables can have a `price` column which isn't a join key. But for
stats this idea of a natural join could be really useful. The question is:
give us everything that can possibly be of interest for the observational
unit in some particular table. Then we keep left joining to that table!

Here's the algorithm:

__Assumptions__
- Column names match if and only if they can be used as a join between
  tables.
- It only makes sense to join if the `target_table` has a one to one or
  many to one relationship with `table`. Otherwise if it has something like
  a one to many relationship then we don't know which rows to bring over for
  the observational unit.

__Input__
- `db` table name of interest, ie. 1 row is 1 observational unit
- `target_table` table name of interest, ie. 1 row is 1 observational unit

```
while True:
    for table in db:
        if table can be joined to target_table:
            target_table = left join target_table to table
    if no table could be joined on the for loop:
        break, we're done
```

Can we think of this as a graph traversal?


## Use case

Going off the retail data idea. Suppose we have these tables:

`line_item` with columns: `order_id, product_id, price, returned`. The
first two are join keys to the other tables. `price` is what they paid
for the item and `returned` is logical indicating whether they have
returned the item.

The following tables are keyed on their name, and there's a one to many
relationship between these tables and the `line_item`, ie. there's only
one entry for each order in the `order` table, and it may contain
many items.

`order` is keyed on `order_id` and has columns such as `customer_id,
time_ordered, ship_zip_code, coupon_code` and computed columns such as
`total_order_value`.

`customer` is keyed on `customer_id` has columns such as `name, email` and
computed columns such as `number_orders, total_dollars_spent,
total_dollars_returned`.

`product` is keyed on `product_id` and has columns such as `color`, `size`,
and computed columns such as `number_sold`.

A natural join across all four tables will produce a table with the same
number of rows as the `line_item`, and number of columns = 2 + the total
number of columns in the other tables. This could be a huge number of
columns, and we potentially need them all for analysis. The idea then is
that we can preserve memory by creating them on demand.

We can keep extending this. For example, a table on zip codes may be
interesting, and that comes from a join on `Order`.

The premise is that all the tables together will fit in memory, but if we
join them then they won't. But we would like to compute on them as if they
were held in memory. So we think of it as an "abstract data frame".

We need to clearly specify how to join these tables to make the view. In
SQL that would look something like:

```

CREATE VIEW line_item_full AS
SELECT * 
FROM line_item l, order o, customer c, product p
WHERE l.product_id = p.product_id
AND l.order_id = o.order_id
AND o.customer_id = c.customer_id
;

```

Suppose we want to check how the item return rate varies based on the hour of
the day that the order was placed. Here's a reasonably efficient way to do
this in R:

```{R}

# Assume this function is available
order$hour = extract_hour(order$time_ordered)

hour_return = merge(line_item[, c("order", "returned")]
    , order[, c("order", "hour")]
    , all.x = TRUE
    , all.y = FALSE
    )

# This also can be much more efficient if hour is a categorical
# variable. Just make the table and use that.
fit = glm(returned ~ hour, data = hour_return, family = binomial())

```

This should be more efficient in terms of run time because we compute the function
`extract_hour()` on the smaller `order` table rather than on the larger
`line_item` table. If on average there are `p` items per order then this
saves time by a factor of `p` for this function call. This is kind of like
caching the result of a function, but it doesn't have to check the
arguments every time.

It's also more efficient in terms of memory usage because it won't create
the unnecessary vector of `time_ordered` in the `hour_return` table.

This example isn't terribly difficult to reason about and express in R, but
add a couple more joins and intermediate computations and it will become
difficult. This is why we would like a system to manage it for us.
Thus we would rather write:

```{R}

line_item_full$hour = extract_hour(line_item_full$time_ordered) 

fit = glm(returned ~ hour, data = line_item_full, family = binomial())

```

These two lines are specific to the computation at hand, while the
`merge()` call in the previous example can be inferred given the schema.

The system must infer that `returned, time_ordered` are the two necessary columns,
and then figure out an efficient way to make the join. I'm sure there's all
kinds of stuff in the DB literature on how to make efficient joins.


### Out of memory

If the full tables don't fit in memory but each column fits in memory we
can do something like this:

```

# The order of this script is very important- the ordering can minimize the
# memory required.

# "order" is a table stored on disk.
# read_columns extracts columns that it needs.
# Since it's two columns it's a data.frame
order = read_columns(name = "order", column = c("order", "time_ordered"))

order$hour = extract_hour(order$time_ordered)

# Free the memory, since we know this will not be used again.
order$time_ordered = NULL 

line_item = read_columns(name = "line_item", column = "order")
# Single column starts as a vector
line_item = as(line_item, "data.frame")

hour_return = merge(line_item
    , order
    , all.x = TRUE
    , all.y = FALSE
    , sort = FALSE
    )

rm(line_item)
hour_return$order = NULL 

hour_return$returned = read_columns(name = "line_item", column = "returned")

fit = glm(returned ~ hour, data = hour_return, family = binomial())

```

The principles at work in this code are:
- Wait until the last possible moment to read something into memory.
- Remove objects as soon as they are no longer needed.


## Caching

This problem assumes that we have limited memory. The system should use as
much of that memory as possible. Although we may not be able to keep
`line_item_full` in memory it should be possible to keep some of the
columns around, or even subsets of the rows. When memory becomes
constrained we can eject the least recently used pieces and write them to
disk. Although it may be faster to recreate them by performing the join
again rather than reading from disk.


## Code Analysis Tasks
