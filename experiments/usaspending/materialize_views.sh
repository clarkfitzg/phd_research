#### Dump Variables ####
DUMP=/scratch/clarkf/usaspending/dump

# =========================================================================
# ==== Comment or remove below if you do not want to materialize views ====
# =========================================================================
#### Materialized View Refresh ####
# Create list of ONLY materialized views data to refresh

# Something seems to be going wrong when I copy and paste versus when I
# type these out in the terminal. Could it be some weird unicode character
# messing things up?

pg_restore --list $DUMP | grep "MATERIALIZED VIEW DATA" > refresh.list

# Refresh materialized view data
pg_restore \
--jobs 16 \
--verbose \
--exit-on-error \
--use-list refresh.list \
$DUMP

# The above doesn't actually populate the materialized views.
# Could be a difference in the version of Postgres for the instructions and
# the version we are using here.

# To actually populate them we need to run:

# REFRESH MATERIALIZED 

# Helpful answer to show which are the materialized views.
# https://stackoverflow.com/questions/23092983/is-there-a-postgres-command-to-list-drop-all-materialized-views

# Do an additional ANALYZE on the materialized views after being materialized
pg_restore --list $DUMP \
| grep "MATERIALIZED VIEW DATA" \
| awk '{ print "ANALYZE VERBOSE", $8";" };' \
> analyze_matviews.sql

psql \
--echo-all \
--set ON_ERROR_STOP=on \
--set VERBOSITY=verbose \
--set SHOW_CONTEXT=always \
--file analyze_matviews.sql
