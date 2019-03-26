COPY (
SELECT keyword_ts_vector FROM universal_transaction_matview
ORDER BY recipient_unique_id
--LIMIT 10
)
to STDOUT With CSV HEADER DELIMITER ',';
