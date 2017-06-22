-- Debugging with a single table
--LOAD DATA INPATH 'pems/' INTO TABLE pems;


-- This loads all the gz files into hive.
-- Took 15 seconds. Presumably it didn't actually do decompression
--LOAD DATA INPATH 'pems' INTO TABLE pems;

-- Then I can check it with
-- SELECT COUNT(*) FROM pems;
-- Takes 49 seconds to return
-- 2598111903
