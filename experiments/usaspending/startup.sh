export PGBIN=/home/clarkf/dev/postgres/postgresql-10.4/install/bin
export PGDATA=/scratch/clarkf/usaspending/postgres

$PGBIN/initdb

#$PGBIN/pg_ctl ‐D $PGDATA start

$PGBIN/pg_ctl start
