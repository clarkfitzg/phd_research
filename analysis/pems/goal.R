# Mon Jun  5 10:53:07 PDT 2017
#
# Now I actually have to be thinking about the file storage format. Best
# would be:
# 
# popular
# lightweight
# fast
# column major
# language agnostic
# precision preserving (probably means binary)
#
# The simplest thing I can imagine to get the column major is to just save
# every column as it's own file. Will this help at all?


# This script is how I'd like to do my traffic data analysis preprocessing:

alldata = read.csv("abstract_file_containing_all_data.csv")

stations = by(alldata, alldata$station, traffic::robust_triangle_fd)

write.csv(stations, "stations.csv")
