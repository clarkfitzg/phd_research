-- Time taken: 407.014 seconds, Fetched: 3722 row(s)
-- 
-- real    6m59.997s
-- user    0m45.471s
-- sys     0m2.942s

SELECT station, MAX(flow1) FROM pems_clustered
GROUP BY station;
