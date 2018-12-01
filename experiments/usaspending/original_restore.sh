#### Connection Variables ####
DBUSER=root
DBPASSWORD=password
DBHOST=127.0.0.1
DBPORT=5432
CONN=postgresql://$DBUSER:$DBPASSWORD@$DBHOST:$DBPORT
DBNAME=data_store_api
#### Dump Variables ####
DUMP_DIR=/dump/data0
DUMP=$DUMP_DIR/usaspending‐db‐dump‐dir
#### Database Restore ####
# DROP and CREATE the database, if it exists
psql $CONN/postgres ‐c \
"DROP DATABASE IF EXISTS $DBNAME"
psql $CONN/postgres ‐c \
"CREATE DATABASE $DBNAME"
# Create list of ALL EXCEPT materialized views data (defer them), to restore
pg_restore ‐‐list $DUMP | sed '/MATERIALIZED VIEW DATA/d' > $DUMP_DIR/restore.list
# Restore all but materialized view data
pg_restore \
‐‐jobs 16 \
‐‐dbname $CONN/$DBNAME \
‐‐verbose \
‐‐exit‐on‐error \
‐‐use‐list $DUMP_DIR/restore.list \
$DUMP
# Perform an ANALYZE to optimize query performance in view materialization
psql \
‐‐dbname $CONN/$DBNAME \
‐‐command 'ANALYZE VERBOSE;' \
‐‐echo‐all \
‐‐set ON_ERROR_STOP=on \
‐‐set VERBOSITY=verbose \
‐‐set SHOW_CONTEXT=always

# =========================================================================
# ==== Comment or remove below if you do not want to materialize views ====
# =========================================================================
#### Materialized View Refresh ####
# Create list of ONLY materialized views data to refresh
pg_restore ‐‐list $DUMP | grep "MATERIALIZED VIEW DATA" > $DUMP_DIR/refresh.list
# Refresh materialized view data
pg_restore \
‐‐jobs 16 \
‐‐dbname $CONN/$DBNAME \
‐‐verbose \
‐‐exit‐on‐error \
‐‐use‐list $DUMP_DIR/refresh.list \
$DUMP
# Do an additional ANALYZE on the materialized views after being materialized
pg_restore ‐‐list $DUMP \
| grep "MATERIALIZED VIEW DATA" \
| awk '{ print "ANALYZE VERBOSE", $8";" };' \
> $DUMP_DIR/analyze_matviews.sql
psql \
‐‐dbname $CONN/$DBNAME \
‐‐echo‐all \
‐‐set ON_ERROR_STOP=on \
‐‐set VERBOSITY=verbose \
‐‐set SHOW_CONTEXT=always \
‐‐file $DUMP_DIR/analyze_matviews.sql
