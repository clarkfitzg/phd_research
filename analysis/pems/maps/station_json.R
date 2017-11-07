library(RJSONIO)
library(RColorBrewer)

station_cluster = read.csv("../station_cluster.csv")

#sapply(station_cluster, class)

message(nrow(station_cluster), " lines in station_cluster.csv")

stations = read.table("~/data/pems/stations.txt", header = TRUE
                      , sep = "\t", quote = "")

# Somehow we went from 1691 to 1664, and I don't know why

s1 = station_cluster$ID
s2 = stations$ID

length(intersect(s1, s2))
# I have no idea why these 27 stations are missing. Come back to it later.
setdiff(s1, s2)

station_cluster = merge(station_cluster
        , stations[, c("ID", "Latitude", "Longitude", "Type", "Lanes", "Dir", "Fwy")]
        )

# Add the color in at this point
display.brewer.all(colorblindFriendly = TRUE)

nclust = length(unique(station_cluster$cluster))

pal = RColorBrewer::brewer.pal(nclust, "Dark2")

# Maybe just 2 colors, brewer.pal always gives 3
pal = pal[1:nclust]

station_cluster$color = pal[station_cluster$cluster]


jstation = toJSON(station_cluster, digits = 10)


message(nrow(station_cluster), " lines written to JSON")

writeLines(jstation, "station.json")
