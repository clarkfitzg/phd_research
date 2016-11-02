# Sat Aug 27 14:57:36 KST 2016
# Looking at the raw files now
#
# 10 million rows in the Bay Area traffic raw station data
# Uncompressed it's 648 MB. For a single day.
# Records seem pretty complete back to 2002.
# 10 districts, say on average 0.2 GB each, for 15 years =>
# ~ 10 TB of data. Wow.
10 * 0.2 * 365 * 15

# 
# This looks like a pretty awesome application
#
# You could actually answer the question: in heavy traffic, is it better to
# be in the fast or slow lane?
#
# Another rad application would be to visualize the effect of an accident
# or road work. To do this you would join the CHP incidents table in
# and represent the structure of the road network
#
# A simple thing that people care about: 
#   the speed of traffic at a given point in time
#   (Google maps does this)
# I'll bet that it would be pretty easy to model using this data.

# Wow, this takes ~20 seconds
station <- read.csv("~/data/d04_text_station_raw_2016_08_25.txt"
                , header = FALSE , stringsAsFactors = FALSE)

# This is 1.3 GB in R. Sweet :)
print(object.size(station), units="GB")

dim(station)

# Inferring this structure from the field spec in download
nlanes = (ncol(station) - 2) / 3
lanenames = paste0(rep(c("flow", "occupancy", "speed"), nlanes), 
                   rep(seq.int(nlanes), each = 3))

# Flow is number of vehicles
# Occupancy of lane between 0 and 1
# Speed in mph
colnames(station) = c("timestamp", "station", lanenames)

sapply(station, class)

# So the last few columns are mostly NA. 
# Notice here also that they all except for 1 have flow and occupancy for
# the first lane.
station_na = sapply(station, function(x) sum(is.na(x)))
station_na 

station[1:10, 1:12]

head(station)

# If these observations happen every 30 seconds for a 24 hour period then
# number of observations per station should be:
2 * 60 * 24 

# Incredible!! It's almost perfectly complete in this respect!
table(table(station$station))

hist(station$flow1)

hist(station$occupancy1)

# clean this up a bit
spd = with(station, speed1[(!is.na(speed1)) & (speed1 < 200)])

# 68 percent of data
length(spd) / nrow(station)

hist(spd)

# 77 seems pretty fast for average mph. Maybe this is km/hr?
mean(spd[50 < spd & spd < 100])

