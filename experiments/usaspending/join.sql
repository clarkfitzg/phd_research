
-- How large should the table be after the join?
-- 103,373,253
-- I expect that every recipient ID should be matched against the table

SELECT COUNT(*)
FROM transaction_normalized
WHERE recipient_id IS NOT NULL
;


-- Verify we get some results
SELECT t.funding_amount, r.recipient_name
FROM transaction_normalized as t
JOIN recipient_profile as r
ON CAST(t.recipient_id AS TEXT) = r.recipient_unique_id
LIMIT 5
;


-- How many are actually matched?
-- 70,037
SELECT COUNT(*)
FROM transaction_normalized as t
JOIN recipient_profile as r
ON CAST(t.recipient_id AS TEXT) = r.recipient_unique_id
;


-- How many are actually matched?
-- 3,153,743
SELECT COUNT(*)
FROM transaction_normalized as t
JOIN recipient_lookup as r
ON t.recipient_id = r.id
;

-- How big is the legal_entity table?
SELECT COUNT(*) FROM legal_entity;
--    count
-- -----------
--  123,618,669
-- (1 row)


-- How many are actually matched?
-- Almost all of them.
SELECT COUNT(*)
FROM transaction_normalized as t
JOIN legal_entity as l
ON t.recipient_id = l.legal_entity_id
;
--    count
-- -----------
--  103,373,253


-- create a table with just the ones that we want.
-- doesn't work- this has 71604797 recipient id's
CREATE TABLE legal_entity2 AS (
    SELECT * FROM legal_entity
    WHERE legal_entity_id IN 
        (SELECT DISTINCT recipient_id FROM awards)
);


-- Which means that we need to get recipient some other way.
SELECT COUNT(DISTINCT recipient_hash)
FROM universal_transaction_matview
;


-- If recipient_hash works as a join key, then this should have close to the same number of records as universal_transaction_matview, 103 million.
SELECT COUNT(*)
FROM recipient_lookup AS r 
JOIN universal_transaction_matview AS t ON r.recipient_hash = t.recipient_hash
;
-- Thank God.

--    count
-- ---------
--  102,476,631
