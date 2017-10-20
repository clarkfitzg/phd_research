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


