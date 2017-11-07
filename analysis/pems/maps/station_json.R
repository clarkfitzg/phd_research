library(RJSONIO)

station_cluster = read.csv("../station_cluster.csv")

sapply(station_cluster, class)

message(nrow(station_cluster), " lines in station_cluster.csv")

stations = read.table("~/data/pems/stations.txt", header = TRUE
                      , sep = "\t", quote = "")

station_cluster = merge(station_cluster
        , stations[, c("ID", "Latitude", "Longitude", "Type", "Lanes")]
        )

# Somehow we went from 1691 to 1664, and I don't know why

jstation = toJSON(station_cluster, digits = 10)


message(nrow(station_cluster), " lines written to JSON")

writeLines(jstation, "station.json")
