# I need to get a server running 
# From https://files.usaspending.gov/database_download/usaspending-db-setup.pdf

DBNAME=usaspending
#### Dump Variables ####
DUMP_DIR=/scratch/clarkf/usaspending
DUMP=$DUMP_DIR/usaspending‐db‐dump‐dir

#### Database Restore ####
# DROP and CREATE the database, if it exists
psql postgres ‐c \
"DROP DATABASE IF EXISTS $DBNAME"
psql postgres ‐c \
"CREATE DATABASE $DBNAME"
# Create list of ALL EXCEPT materialized views data (defer them), to restore
pg_restore ‐‐list $DUMP | sed '/MATERIALIZED VIEW DATA/d' > $DUMP_DIR/restore.list

# Restore all but materialized view data
pg_restore \
‐‐jobs 16 \
‐‐dbname $DBNAME \
‐‐verbose \
‐‐exit‐on‐error \
‐‐use‐list $DUMP_DIR/restore.list \
$DUMP
