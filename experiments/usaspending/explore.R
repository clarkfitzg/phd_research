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

examples = lapply(df$table[1:10], head_table)
names(examples) = df$table[1:10]

names(examples)

# Interesting ones:
# transaction_normalized
# transaction_fpds
# transaction_fabs award_description, cfda_title

names(examples[[10]])
