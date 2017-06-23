Copied 24 GB of compressed pems data into HDFS. Took about 5 minutes, which
comes out to 80 MB / second, expected IO performance of a single disk.

The `put` command copies from local to HDFS:

```
clarkf@hadoop ~/pems
$ hdfs dfs -put *.txt.gz pems
```

Now I will try to write a Python Spark program to do the station split.
Actually, makes more sense to use a database, ie ingest into hive.

Start out with some tiny file exemplifying what I would like to do.

```
gzip -cd tiny.txt.gz
```

Running Hive 1.2.1000

Now I run the two hive scripts to create my table and load data into it.
After loading the data does not exist in HDFS any longer.

This 'weekday mapper' script is extremely interesting.
https://cwiki.apache.org/confluence/display/Hive/GettingStarted
It maps an arbitrary Python script onto the data. Curious that it uses
stdin / stdout to transfer the data via text. This means that both hive and
Python have to specify the datatypes / parse the strings. It would seem
better to pass the correct datatype over in Python. Maybe that is what
Spark offers. But R could do this reasonably well for a group by / apply
operation.

This experiment was surprisingly successful. The next step is to run it on
the whole data and time it. First I need to probably unzip these .gz files.

Thu Jun 22 16:57:25 PDT 2017

Turns out unzipping is not necessary, hive figures that out for me. After I
run the query using just a single days worth of data I see that 3096 new
folders are created within the `pemsstation` directory, as expected based
on how I made that table. A single 100 MB file took 38 minutes to 
process, which is much slower than R.

Hive made dynamic partitions based on the values that it saw for station. I
think 3000 small files may be not ideal for Hadoop, it required changing
some defaults in hive. Conventional wisdom is that larger files amortize some of the
overhead associated with Hadoop.

Takes 4.5 minutes to load the gzipped files from local into Hadoop, this
time using hive rather than `hdfs dfs put`. Somehow I had deleted them
earlier.

The following code should increase the number of files I can have open. 

```
clarkf@hadoop ~/phd_research/hadoop (master)
$ ulimit -n 4096
clarkf@hadoop ~/phd_research/hadoop (master)
$ ulimit -n
4096
```

When I attempt to load the data with the partitions again the same error:
```
java.lang.OutOfMemoryError: unable to create new native thread.
```

OK. So maybe the next step is to try to execute this on Spark or map
reduce.

Fri Jun 23 08:55:55 PDT 2017

Trying to partition using the Python interface. I used the `write.parquet`
interface
https://spark.apache.org/docs/1.6.0/api/python/pyspark.sql.html#pyspark.sql.DataFrameWriter.parquet
which supports selecting the partition. Along the way I saw something like
"too many partitions, falling back to sorting". This should be fine.
Maybe should have tried this on a smaller subset first. Looking at top the
java command seems to be using 2800 % CPU, which means at least something
is happening. As it runs there is a `_temporary` file in the `pems_python`
directory, so my arguments are likely correct.
