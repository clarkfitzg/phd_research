# Fri Jun 30 11:18:10 PDT 2017
#
# Determine the latitude and longitude for the stations so that they can be
# plotted.

station_cluster = read.csv("station_cluster.csv")

stations = read.table("~/data/pems/stations.txt", header = TRUE
                      , sep = "\t", quote = "")

station_cluster = merge(station_cluster
        , stations[, c("ID", "Latitude", "Longitude", "Type", "Lanes")]
        )


# The below shows that nearly all detectors of type "OR", which I believe
# corresponds to on ramp, are in the strange 3rd cluster. Also detectors of
# type "FR". Behavior on an on ramp should be quite a bit different than on
# the normal freeway. So I should go back and restrict the clustering just
# to stations of type "ML".

cluster3 = station_cluster$cluster == 3
s12 = station_cluster[!cluster3, ]
s3 = station_cluster[cluster3, ]

plot(s12$Type)

plot(s3$Type)
