# Sat Aug 27 11:59:04 KST 2016
#
# Pems has some interesting looking data sets.
# http://pems.dot.ca.gov/?dnode=Clearinghouse&type=gn_link_5min&district_id=all&submit=Submit
# Lets check it out

# Have to manually add these
columns <- read.table("~/phd_research/data/caltrans_link_header.txt"
                , header = TRUE, sep = "|", comment.char = ""
                , stringsAsFactors = FALSE)

# This is one day of the 5 minute link data, file is 213 MB when
# uncompressed.
link5 <- read.csv("~/data/contracted-Caltrans_text_gn_link_5min_2016_08_25.txt"
                , header = FALSE , stringsAsFactors = TRUE
                , col.names = columns$name)

# Looks good
sapply(link5, class)

# Sanity checks
hist(link5$avg_speed)

# They almost all had 5 samples, maybe every minute?
hist(link5$samples)

# This shows they're essentially either all high quality, or all low for
# one 5 minute period.
hist(link5$high_quality_samples / link5$samples)

# 31K links
length(unique(link5$source_id))

# If every link gets measured every 5 minutes then there should be
12 * 24
# rows per link

nobs <- table(link5$source_id)

# These are all over the place.
hist(nobs)

# But it's not necessarily bad data, maybe some links don't have any
# traffic in 5 minutes, so there is no row. That makes sense.
max(nobs)


