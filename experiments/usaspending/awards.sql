SELECT a.id
    , a.total_obligation
    , a.period_of_performance_start_date
    , a.description
    , a.funding_agency_id
    , a.recipient_id
    , s.name
FROM awards AS a
JOIN subtier_agency AS s
ON a.funding_agency_id = s.subtier_agency_id
--LIMIT 10
;
