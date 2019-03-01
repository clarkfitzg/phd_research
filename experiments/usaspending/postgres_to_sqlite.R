library(DBI)
library(RPostgreSQL)

CHUNKSIZE = 1e4L

from_db = dbConnect(drv = dbDriver("PostgreSQL"))

to_db = dbConnect(RSQLite::SQLite(), "/scratch/usaspending/usaspending.sqlite")

table_names = data.frame(
    from = c("transaction_normalized", "recipient_lookup")

    )

# The stream of incoming data
# This takes forever => it's NOT streaming
system.time(res <- dbSendQuery(from_db, "SELECT * FROM universal_transaction_matview"))

# Use the first row to initialize things
first_row = dbFetch(res, n = 1L)
dbCreateTable(to_db, "transactions", first_row)
#dbAppendTable(to_db, "transactions", chunk)

while(!dbHasCompleted(res)){
    chunk = dbFetch(res, n = CHUNKSIZE)
    dbAppendTable(to_db, "transactions", chunk)
}


dbClearResult(res)

dbDisconnect(from_db)
dbDisconnect(to_db)
