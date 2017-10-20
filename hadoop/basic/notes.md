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


# Error Handling

A program that prints a single line causes this error:

```
Caused by: java.io.IOException: Stream closed
```

I believe this comes from not reading from `stdin`. Yes, ok finally.  Then
not opening `stdin` causes an error from the Java end. Looking at the error
logs I can see R errors that occur first.  Also seeing `pipe broken` error
messages.

Before running it with the full data set it's a good idea to get it working
with a local version. For example, the same error appears both locally and
in the cluster. `little.txt` is the first 10 records to be processed.

```
$ cat little.txt | Rscript udaf.R
Error in `[.data.frame`(tbl, , 1:2) : undefined columns selected
Calls: aggregate -> aggregate.data.frame -> [ -> [.data.frame
Execution halted
```

# Checking logs

Scripts will fail. After unintentionally writing a few with bugs I wrote a
few very minimal scripts where I purposely injected bugs in various
locations and then reviewed the logs. This is helpful to figure out what is
happening.

When the R script fails we need to look at the traceback so we can learn
something about why it failed. A couple blog post tutorials catch the error
in the script and write the traceback into the table. This technique works
with R, but mixes data with error logs. The system already logs `stderr`,
so we just need to find where to read those logs. Moreover, we can write to
`stderr` for logging purposes in a regular script that doesn't fail.

When I run the hive query I see a line like this indicating the YARN application ID:

```
Status: Running (Executing on YARN cluster with App id application_1480440170646_0140)
```

We can used this ID to inspect the logs:

```
$ yarn logs -applicationId application_1480440170646_0140 -log_files stderr | less

yarn logs -applicationId application_1480440170646_0144 -log_files stderr | less

```
