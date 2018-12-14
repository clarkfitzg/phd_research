library(RPostgreSQL)

conn = dbConnect(drv = dbDriver("PostgreSQL")
    , dbname = "postgres"
    , host = "localhost"
    , port = 5432
    )
