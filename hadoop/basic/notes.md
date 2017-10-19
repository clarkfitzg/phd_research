This 'weekday mapper' script is extremely interesting.
https://cwiki.apache.org/confluence/display/Hive/GettingStarted
It maps an arbitrary Python script onto the data. Curious that it uses
stdin / stdout to transfer the data via text. This means that both hive and
Python have to specify the datatypes / parse the strings. It would seem
better to pass the correct datatype over in Python. Maybe that is what
Spark offers. But R could do this reasonably well for a group by / apply
operation.

Tue Oct 17 10:18:31 PDT 2017

When I try again here to run something similar with R I see:

```
Caused by: java.io.IOException: Cannot run program "Rscript": error=2, No
such file or directory
```
 
This may mean that the `Rscript` command is not available on the worker
nodes? Indeed, that was the same error as the original one, had I dug
through it more carefully!

Yes, this was the error.

# Gamma Function Example

The gamma example uses exactly the same idea as the weekday mapper script
referenced above. The workers execute `Rscript`, reading from the data from
`stdin` and writing to `stdout`. `gamma()` works in a vectorized way,
mapping each row into another row.

On this sample dataset with 100K rows a single R process handled all the
data. The actual model is a streaming transformation, which R is not doing.
R can only process batches at a time, since it's so expensive to go row by
row. R will fail to consume the whole stream once it becomes large enough.
We can get around this by having a streaming mechanism either from Hive or
R. If it comes from the Hive side it needs to send only a fixed amount of
data before starting a new process. If it comes from the R side we need to
stop and process once enough data comes in.

This can be understood like a traffic signal. Rows of data in a table are
vehicles. We first wait to accumulate `n` rows to amortize the cost of the vector
operations. Next we process them all and release them.

I think it makes more sense to do it all from the R side, since this would
be useful for things other than Hive, and it's more natural to think of
the streaming transforms in Hive. Ie. Hive developers shouldn't have to
write anything R specific. I wonder how well `iotools` supports this
streaming model, since it was created to work with Hadoop.
