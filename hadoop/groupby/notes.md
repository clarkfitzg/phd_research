Thu Oct 19 11:12:24 PDT 2017

Now attempting to get a user defined aggregation function working.

Loosely following this blog post:
http://www.florianwilhelm.info/2016/10/python_udf_in_hive/

I'm attempting to do the SQL equivalent of: 

```

SELECT userid, COUNT(*) as n
FROM u_data
GROUP BY userid
ORDER BY n DESC
LIMIT 10
;

```

It's nice to first do something that SQL can do, because then we can verify
the answer. Of course the whole point of using R is to go beyond what SQL can
do.

An interesting application would be to actually totally randomize the order
of the rows
for files in HDFS. This could be done by adding a random integer column in
R. Some similar approaches:
http://www.joefkelley.com/736/
