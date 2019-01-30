library(DBI)
library(RPostgreSQL)


con = dbConnect(drv = dbDriver("PostgreSQL"))


query = readLines("/scratch/clarkf/usaspending/transactions.sql")
query = paste(query, collapse = "")

rs = dbSendQuery(connection, query)

dbFetch(rs)


on.exit(dbClearResult(rs))

names(trns)

dbDisconnect(con)
