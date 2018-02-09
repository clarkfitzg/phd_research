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
