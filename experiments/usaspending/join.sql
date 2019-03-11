
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


-- How many are actually matched?
-- 
SELECT COUNT(*)
FROM transaction_normalized as t
JOIN legal_entity as l
ON t.recipient_id = l.legal_entity_id
;

