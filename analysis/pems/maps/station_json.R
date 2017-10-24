library(RJSONIO)

station = read.csv("../station_cluster.csv")

jstation = toJSON(station, digits = 10)

message(nrow(station), " lines written.")

writeLines(jstation, "station.json")
