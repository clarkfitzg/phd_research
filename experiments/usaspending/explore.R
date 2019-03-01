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

df = data.frame(table = tbls, nrow = unlist(nrows))
row.names(df) = NULL

df = df[order(df$nrow, decreasing = TRUE), ]


head_table = function(tbl, n = 10, connection = con)
{
    message(tbl)
    rs = dbSendQuery(connection, paste0("SELECT * FROM ", tbl, " LIMIT ", n))
    on.exit(dbClearResult(rs))
    dbFetch(rs)
}

examples = lapply(df$table, head_table)
names(examples) = df$table

names(examples)

# Interesting ones:
# transaction_normalized
# X awards
# transaction_fpds
# transaction_fabs award_description, cfda_title

names(examples[[10]])

examples[[3]]

trns = head_table("universal_transaction_matview")

names(trns)

x = dbGetQuery(con, "SELECT * FROM recipient_lookup LIMIT 10")

# Works
j = dbGetQuery(con, "SELECT * FROM recipient_lookup AS a JOIN transaction_normalized AS b on a.id = b.recipient_id LIMIT 10")

# Works
j2 = dbGetQuery(con, "SELECT * FROM toptier_agency AS a JOIN transaction_normalized AS b on a.toptier_agency_id = b.funding_agency_id LIMIT 10")



dbDisconnect(con)
