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
Spark offers.

This experiment was surprisingly successful. The next step is to run it on
the whole data and time it. First I need to probably unzip these .gz files.
