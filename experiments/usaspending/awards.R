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

awards$funding_agency_id[is.na(awards$funding_agency_id)] = 0L

# Save it split into groups
system.time(
by(awards, awards$funding_agency_id, function(group){
    datadir = "/scratch/usaspending/awards"
    fname = paste0(datadir, "/", group[1, "funding_agency_id"], ".csv")
    write.csv(group, fname, row.names = FALSE)
})
)

# Exploring

# Did any fail to match in the join?
failmatch = awards[(is.na(awards$funding_agency_name) & awards$funding_agency_id != 0), ]

# Only agency 1474, whatever that is.
table(failmatch$funding_agency_id)

# 6 GB
print(object.size(awards), units = "GB")

sapply(awards, class)

agencies = table(awards$funding_agency_name)
agencies = sort(agencies, decreasing = TRUE)

# scaled
a2 = agencies / nrow(awards)
