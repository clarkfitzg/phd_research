library(RSQLite)
library(RSQLiteUDF)


db <- dbConnect(RSQLite::SQLite(), ":memory:")
data(USArrests)
dbWriteTable(db, "USArrests", USArrests)
dbListTables(db)


# Load RSQLiteUDF and the RSQLite extensions
sqliteExtension(db) # want the floor function from RSQLite extensions.

d = dbGetQuery(db, "SELECT murder FROM USArrests LIMIT 5")


ptr = getNativeSymbolInfo("myfloorFunc")$address



createSQLFunction(db, db@ptr, ptr, nargs = 1L, "myfloor")

#createSQLFunction(db, db@ptr, ptr, nargs = 1L, "myfloor")

# Error in createSQLFunction(db, ptr, nargs = 1L, "myfloor") :
# no slot of name "Id" for this object of class "SQLiteConnection"


#createSQLFunction(db, ptr, 1L, "myfloor")


