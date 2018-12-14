library(DBI)

library(RPostgreSQL)


con = dbConnect(drv = dbDriver("PostgreSQL"))

count_star = function(tbl, connection = con)
{
    message(tbl)
    rs = dbSendQuery(connection, paste0("SELECT COUNT(*) FROM ", tbl))
    on.exit(dbClearResult(rs))
    dbFetch(rs)
}

tbls = dbListTables(con)

count_star("psc")

nrows = sapply(tbls, count_star)
