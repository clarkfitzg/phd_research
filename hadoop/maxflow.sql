-- Takes 78 seconds total
-- 66 seconds for query, the rest for startup
SELECT station, MAX(flow1) FROM pems_parquet_comp
GROUP BY station;
