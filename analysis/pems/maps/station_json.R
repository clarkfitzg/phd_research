library(RJSONIO)

station = read.csv("../station_cluster.csv")

jstation = toJSON(station, digits = 10)

writeLines(jstation, "station.json")
