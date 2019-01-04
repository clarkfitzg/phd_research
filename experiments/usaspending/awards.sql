--DROP TABLE awards_with_agency;

--CREATE TEMP TABLE awards_with_agency AS
SELECT a.id
    , a.total_obligation
    , a.period_of_performance_start_date
    , a.description
    , a.recipient_id
    , a.funding_agency_id
    , s.name AS funding_agency_name
FROM awards AS a
LEFT JOIN subtier_agency AS s
ON a.funding_agency_id = s.subtier_agency_id
-- LIMIT 20
;
