# Thu Oct 26 15:49:06 PDT 2017
#
# This needs to process the data as a stream from stdin.
# The CLUSTER BY query guarantees that each station will be contiguous in the
# stream.
# 
# Concepts
# ===========
# working batch- The whole chunk to process. A single chunk, and in
#   particular the _largest_ such chunk should fit comfortably in memory.
# queue- Data that has been read from stdin, but is not part of the working
#   chunk because it comes from the next group

# Each working chunk to process has around 800K rows, so make this parameter larger
# than 800K. 
CHUNKSIZE = 1e6L

# Columns for the variables of interest. It would be better to do this by
# name based on the Hive table.
FLOW2_INDEX = 7
OCC2_INDEX = 8

# Parameters related to analysis
LEFT_RIGHT = 0.1
MIDDLE_LEFT = 0.2
MIDDLE_RIGHT = 0.5
RIGHT_LEFT = 0.5


stream_in = file("stdin")
open(stream_in)
stream_out = stdout()

queue = read.table(stream_in)

# All psuedocode at the moment:
while(nrow(queue) > 0) {
    while(multiple_groups) {
        working = queue[...] #TODO
    }
    # Fill up the queue
    nextqueue = read.table(stream_in)
    queue = rbind(queue, nextqueue)
}

s1 = read.table("~/data/two_stations/000014_0.gz")
names(s1)[FLOW2_INDEX] = "flow2"
names(s1)[OCC2_INDEX] = "occ2"


left_data = s1[s1$occ2 <= LEFT_RIGHT, ]
left_fit = lm(flow2 ~ occ2 -1, left_data)

middle_data = s1[(MIDDLE_LEFT <= s1$occ2) & (s1$occ2 < MIDDLE_RIGHT), ]

middle_fit = lm(flow2 ~ occ2, middle_data)

right_data = s1[RIGHT_LEFT <= s1$occ2, ]
right_fit = lm(flow2 ~ I(occ2 - 1) - 1, right_data)


