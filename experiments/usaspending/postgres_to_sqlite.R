library(DBI)
library(RPostgreSQL)

from_db = dbConnect(drv = dbDriver("PostgreSQL"))

to_db = dbConnect(RSQLite::SQLite(), "/scratch/usaspending/usaspending.sqlite")


# Copy a table between databases in chunks.
# This is an example of using lazy evaluation to make a more flexible interface.
chunk_copy_table = function(from_name
    , to_name = from_name
    , qstring = paste0("SELECT * FROM ", from_name)
    , .from_db = from_db
    , .to_db = to_db
    , chunk_size = 1e5L
    )
{
    # Might be fun to show students what a SQL injection attack is.

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
}


table_names = c("agency"
          , "toptier_agency"
          , "subtier_agency"
          , "state_data"
          , "recipient_profile"
          , "recipient_lookup"
          )

lapply(table_names, chunk_copy_table)

# Make sure it works before I launch the larger one
if(FALSE){

chunk_copy_table(to_name = "trans_test"
    , qstring = "SELECT * FROM universal_transaction_matview LIMIT 10"
    )

dbGetQuery(to_db, "SELECT * FROM trans_test")

}

system.time(
chunk_copy_table("universal_transaction_matview", "transaction_view")
)


dbDisconnect(from_db)
dbDisconnect(to_db)
