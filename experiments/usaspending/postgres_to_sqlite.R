library(DBI)
library(RPostgreSQL)

from_db = dbConnect(drv = dbDriver("PostgreSQL"))

to_db = dbConnect(RSQLite::SQLite(), "/scratch/usaspending/usaspending.sqlite")


# Copy a table between databases in chunks.
chunk_copy_table = function(from_name, to_name, .from_db = from_db, .to_db = to_db, chunk_size = 1e4L)
{
    # Might be fun to show students what a SQL injection attack is.
    qstring = paste0("SELECT * FROM ", from_name)

    # The stream of incoming data
    # This takes 17 minutes for a large table in Postgres
    #    => it's NOT streaming
    print(system.time(res <- dbSendQuery(.from_db, qstring)))
    on.exit(dbClearResult(res))

    # Use the first row to initialize things
    first_row = dbFetch(res, n = 1L)
    dbCreateTable(.to_db, to_name, first_row)

    chunk_index = 1L
    while(!dbHasCompleted(res)){
        chunk = dbFetch(res, n = chunk_size)
        dbAppendTable(.to_db, to_name, chunk)

        message("chunk ", chunk_index)
        chunk_index = chunk_index + 1L
    }

    message("completed ", from_name)
}


table_names = data.frame(
    from = c("toptier_agency", "transaction_normalized", "recipient_lookup"),
    to = c("agency", "transaction", "recipient"),
    stringsAsFactors = FALSE
)


Map(chunk_copy_table, table_names[, "from"], table_names[, "to"])


dbDisconnect(from_db)
dbDisconnect(to_db)
