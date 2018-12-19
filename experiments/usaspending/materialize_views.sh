#### Dump Variables ####
WD=/home/usaspending
DUMP=/scratch/clarkf/usaspending/usaspending-db-dump-dir

# =========================================================================
# ==== Comment or remove below if you do not want to materialize views ====
# =========================================================================
#### Materialized View Refresh ####
# Create list of ONLY materialized views data to refresh

pg_restore ‐‐list $DUMP | grep "MATERIALIZED VIEW DATA" > $WD/refresh.list

# Refresh materialized view data
pg_restore \
‐‐jobs 16 \
‐‐verbose \
‐‐exit‐on‐error \
‐‐use‐list $WD/refresh.list \
$DUMP

# Do an additional ANALYZE on the materialized views after being materialized
pg_restore ‐‐list $DUMP \
| grep "MATERIALIZED VIEW DATA" \
| awk '{ print "ANALYZE VERBOSE", $8";" };' \
> $WD/analyze_matviews.sql

psql \
‐‐echo‐all \
‐‐set ON_ERROR_STOP=on \
‐‐set VERBOSITY=verbose \
‐‐set SHOW_CONTEXT=always \
‐‐file $WD/analyze_matviews.sql
