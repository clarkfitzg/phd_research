--Time taken: 101.775 seconds, Fetched: 3722 row(s)
--
--real    1m54.238s
--user    0m40.197s
--sys     0m2.520s

SELECT station, MAX(flow1) FROM pems
GROUP BY station;
