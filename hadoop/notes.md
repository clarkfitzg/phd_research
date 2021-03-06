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
directory, so my arguments are likely correct. No way to check the time
running interactively as I did here. Will check it when I come back this
weekend.

Mon Jun 26 08:07:39 PDT 2017

Just came back. Seems that it failed right away. Some relevant logs:

```
# Initial command
>>> pems.write.parquet("pems_python", mode="overwrite", partitionBy="station")

...

17/06/23 09:26:14 INFO ColumnChunkPageWriteStore: written 50B for [flow8] INT32: 2,386 values, 7B raw, 27B comp, 1 pages, encodings: [PLAIN, RLE, BIT_PACKED]
17/06/23 09:26:14 INFO ColumnChunkPageWriteStore: written 50B for [occupancy8] DOUBLE: 2,386 values, 7B raw, 27B comp, 1 pages, encodings: [PLAIN, RLE, BIT_PACKED]
17/06/23 09:26:14 INFO ColumnChunkPageWriteStore: written 50B for [speed8] DOUBLE: 2,386 values, 7B raw, 27B comp, 1 pages, encodings: [PLAIN, RLE, BIT_PACKED]
17/06/23 09:26:14 WARN MemoryManager: Total allocation exceeds 95.00% (984,193,408 bytes) of heap memory
Scaling row group sizes to 24.44% for 30 writers
17/06/23 09:26:14 INFO SparkHadoopMapRedUtil: attempt_201706230903_0000_m_000021_0: Not committed because the driver did not authorize commit
17/06/23 09:26:14 ERROR Utils: Aborting task
java.lang.RuntimeException: Failed to commit task
        at org.apache.spark.sql.execution.datasources.DynamicPartitionWriterContainer.org$apache$spark$sql$execution$datasources$DynamicPartitionWriterContainer$$commitTask$2(WriterContainer.scala
:446)
        at org.apache.spark.sql.execution.datasources.DynamicPartitionWriterContainer$$anonfun$writeRows$4.apply$mcV$sp(WriterContainer.scala:408)
        at org.apache.spark.sql.execution.datasources.DynamicPartitionWriterContainer$$anonfun$writeRows$4.apply(WriterContainer.scala:343)
        at org.apache.spark.sql.execution.datasources.DynamicPartitionWriterContainer$$anonfun$writeRows$4.apply(WriterContainer.scala:343)
        at org.apache.spark.util.Utils$.tryWithSafeFinallyAndFailureCallbacks(Utils.scala:1277)
        at org.apache.spark.sql.execution.datasources.DynamicPartitionWriterContainer.writeRows(WriterContainer.scala:409)
        at org.apache.spark.sql.execution.datasources.InsertIntoHadoopFsRelation$$anonfun$run$1$$anonfun$apply$mcV$sp$3.apply(InsertIntoHadoopFsRelation.scala:148)
        at org.apache.spark.sql.execution.datasources.InsertIntoHadoopFsRelation$$anonfun$run$1$$anonfun$apply$mcV$sp$3.apply(InsertIntoHadoopFsRelation.scala:148)
        at org.apache.spark.scheduler.ResultTask.runTask(ResultTask.scala:66)
        at org.apache.spark.scheduler.Task.run(Task.scala:89)
        at org.apache.spark.executor.Executor$TaskRunner.run(Executor.scala:227)
        at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
        at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
        at java.lang.Thread.run(Thread.java:745)
Caused by: org.apache.spark.executor.CommitDeniedException: attempt_201706230903_0000_m_000021_0: Not committed because the driver did not authorize commit
        at org.apache.spark.mapred.SparkHadoopMapRedUtil$.commitTask(SparkHadoopMapRedUtil.scala:131)
        at org.apache.spark.sql.execution.datasources.BaseWriterContainer.commitTask(WriterContainer.scala:219)
        at org.apache.spark.sql.execution.datasources.DynamicPartitionWriterContainer.org$apache$spark$sql$execution$datasources$DynamicPartitionWriterContainer$$commitTask$2(WriterContainer.scala
:443)
        ... 13 more
17/06/23 09:26:14 WARN FileOutputCommitter: Could not delete hdfs://hadoop.ucdavis.edu:8020/user/clarkf/pems_python/_temporary/0/_temporary/attempt_201706230903_0000_m_000021_0
17/06/23 09:26:14 ERROR DynamicPartitionWriterContainer: Task attempt attempt_201706230903_0000_m_000021_0 aborted.
17/06/23 09:26:14 WARN TaskSetManager: Lost task 21.0 in stage 0.0 (TID 21, localhost): TaskCommitDenied (Driver denied task commit) for job: 0, partition: 21, attemptNumber: 0
17/06/23 09:26:14 INFO TaskSchedulerImpl: Removed TaskSet 0.0, whose tasks have all completed, from pool 
17/06/23 09:51:15 INFO BlockManagerInfo: Removed broadcast_1_piece0 on localhost:33805 in memory (size: 35.7 KB, free: 511.1 MB)
17/06/23 09:51:15 INFO ContextCleaner: Cleaned accumulator 2
>>> 
```

Why is heap memory only 1GB? This is exceedingly small. Nothing ended up
being written to disk.

Next step: Write a toy data frame to parquet, see if and how it works.

```

first10 = sqlContext.sql("SELECT * FROM pems LIMIT 10")

first10.write.parquet("pems_python", mode="overwrite", partitionBy="station")

```

This works with no problem.

Mon Jul 17 15:14:00 PDT 2017

Just now tried it again with the whole dataset after increasing the number
of open files to 64K.
Failed after 20 minutes with:

```
pems.write.parquet("pems_station", partitionBy="station")

2K + lines of traceback... most of which looks like:

17/07/17 14:37:07 ERROR DFSClient: Failed to close inode 3126673
org.apache.hadoop.ipc.RemoteException(org.apache.hadoop.hdfs.server.namenode.LeaseExpiredException): No lease on /user/clarkf/pems_station/_temporary/0/_temporary/attempt_201707171417_0000_m_000020_0/station=400000/part-r-00020-be95a8e6-0ab7-4f2e-89b6-5875bcbf24de.snappy.parquet (inode 3126673): File does not exist. [Lease.  Holder: DFSClient_NONMAPREDUCE_1546292922_27, pendingcreates: 1]
        at org.apache.hadoop.hdfs.server.namenode.FSNamesystem.checkLease(FSNamesystem.java:3521)
```

Tue Jul 18 08:37:02 PDT 2017

Came back to check the results just now- failed after 2 hours again.

```
17/07/17 17:22:38 ERROR InsertIntoHadoopFsRelation: Aborting job.
org.apache.spark.SparkException: Job aborted due to stage failure: Task 6 in stage 1.0 failed 1 times, most recent failure: Lost task 6.0 in stage 1.0 (TID 290, localhost): java.lang.OutOfMemoryError: GC overhead limit exceeded
        at java.util.Arrays.copyOf(Arrays.java:3332)
```

The memory limits can be adjusted, but the issue is that I have no clue
what they should be, or how the memory is used.
 
Maybe I can try again to do it totally in Hive, not with Spark.

Tue Jul 18 14:54:23 PDT 2017

Ran the Python version with the executor cores set to 4 GB. This time:

```
java.lang.OutOfMemoryError: GC overhead limit exceeded
```

Fails after 2 hours just as before.


## Finally Success!

Wed Jul 19 09:57:28 PDT 2017

This time used it only through hive.

Time taken is 5841 seconds = 97 minutes for the uncompressed Parquet file. Not bad.


Thu Jul 20 11:54:40 PDT 2017

Problem before was the grouping by station did not happen.
This time I think it will.

Took 98 minutes for the uncompressed Parquet file including grouping.

Thu Aug  3 20:27:39 PDT 2017

Ran it again, grouping by station and storing it as a text file. Took 119
minutes, not much difference from the Parquet.


```

hdfs dfs -cat pems_clustered/000000_0 | head

```

This also seems to have done the grouping by station, although it output
the data in a goofy way. It actually might be fixed width format?
TODO: check default hive formatting.


Wed Sep 13 10:49:45 PDT 2017

Considering the relative file sizes:
```

hdfs dfs -du -s -h pems

```

- 24.1 GB for `pems` compressed daily `txt.gz` files as downloaded from server
- 25.1 GB for `pems_parquet_comp`, Parquet compressed using "Snappy"
- 68.4 GB for `pems_parquet` clustered and stored as parquet
- 261.1 GB for `pems_clustered` plain text with hive formatting

Creation of the `pems_parquet_comp` table from `pems` took 94 minutes. Does
this then facilitate the sort of computation we would like to do?
Here's a basic one:

```
SELECT station, MAX(flow1) FROM pems
GROUP BY station;
```

This query takes 78 seconds with compressed Parquet, and 114 seconds with
the original gz compressed text. So the text is only about 1.5 times slower
than Parquet. The sizes are about the same. The speed improvement is nice,
but it is not a game changer.  And it doesn't justify spending a ton of
time writing R / Parquet bindings.  If Parquet was one or two orders of
magnitude faster that would be a different story.

Side note- performance is impressive regardless considering this requires a
full scan of 2.6 billion rows.
