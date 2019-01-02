library(DBI)
library(RPostgreSQL)


con = dbConnect(drv = dbDriver("PostgreSQL"))

query = readLines("awards.sql")

# Started 8:48, done when I next checked at 8:53
rs = dbSendQuery(con, query)

# 515 seconds? Maybe because this is the second time I did it.
# The first one took over 1 hour.
system.time(awards <- dbFetch(rs))

dbDisconnect(con)

# Exploring

# 6 GB
print(object.size(awards), units = "GB")

sapply(awards, class)

agencies = table(awards$funding_agency_name)
agencies = sort(agencies, decreasing = TRUE)

# scaled
a2 = agencies / sum(agencies)
