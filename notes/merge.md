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

## Use case

Going off the retail data idea. Suppose we have these tables:

`line_item` with columns: `order, product, price, returned`. The
first two are join keys to the other tables. `Price` is what they paid
for the item and `Returned` is logical indicating whether they have
returned the item.

The following tables are keyed on their name, and there's a one to many
relationship between these tables and the `line_item`, ie. there's only
one entry for each order in the `order` table, and it may contain
many items.

`order` has columns such as `customer, time_ordered, ship_zip_code,
coupon_code` and computed columns such as `total_order_value`.

`customer` has columns such as `name, email` and computed columns such as
`number_orders, total_dollars_spent, total_dollars_returned`.

`product` has columns such as `color`, `size`, and computed columns such as
`number_sold`.

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

```

This should be more efficient in terms of run time because we compute the function
`extract_hour()` on the smaller `order` table rather than on the larger
`line_item` table. If on average there are `p` items per order then this
saves time by a factor of `p` for this function call.

It's also more efficient in terms of memory usage because it won't create
the unnecessary vector of `time_ordered` in the `hour_return` table.
