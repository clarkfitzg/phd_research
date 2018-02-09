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

## Use case

Going off the retail data idea. Suppose we have these tables:

`line_items` with columns: `Customer, Order, Product, Price, Returned`. The
first three are join keys to the other tables. `Price` is what they paid
for the item and `Returned` is logical indicating whether they have
returned the item.

The following tables are keyed on their name, and there's a one to many
relationship between these tables and the `line_items`, ie. there's only
one entry for the customer in the `Customer` table, and they may have
purchased many items.

`Customer` has columns such as `name, email` and computed columns such as
`number_orders`.

`Order` has columns such as `ship_state, ship_zip_code, coupon_code` and computed
columns such as `total_order_value`.

`Product` has columns such as `color`, `size`, and computed columns such as
`number_sold`.

A natural join across all four tables will produce a table with the same
number of rows as the `line_items`, and number of columns = 2 + the total
number of columns in the other tables.

We can keep extending this, for example a table on zip codes may be
interesting, and that comes from a join on `Order`.
