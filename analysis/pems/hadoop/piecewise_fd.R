# Thu Oct 26 15:49:06 PDT 2017
#
# This needs to process the data as a stream from stdin.
# The CLUSTER BY query guarantees that each station will be contiguous in the
# stream.
# 
# Concepts
# ===========
# working chunk- The whole chunk to process. The _largest_ such chunk
#   should fit comfortably in memory.
# queue- Data that has been read from stdin, but is not part of the working
#   chunk because it comes from the next group

# Logging to stderr() writes to the Hadoop logs where we can find them.
DEBUG = FALSE
msg = function(..., log = DEBUG)
{
    if(log) writeLines(paste(...), stderr())
}

msg("BEGIN R SCRIPT")

# Each working chunk to process has around 800K rows, so make this parameter larger
# than 800K. 
CHUNKSIZE = 1e6L

# This is the index for the column defining the groups
GROUP_INDEX = 1L

SEP = "\t"

# Columns for the variables of interest. It would be better to do this by
# name based on the Hive table.
col.names = c("station", "flow2", "occ2")
colClasses = c("integer", "integer", "numeric")

# Parameters related to analysis
LEFT_RIGHT = 0.1
MIDDLE_LEFT = 0.2
MIDDLE_RIGHT = 0.5
RIGHT_LEFT = 0.5


stream_in = file("stdin")
open(stream_in)
stream_out = stdout()

multiple_groups = function(queue, g = GROUP_INDEX) length(unique(queue[, g])) > 1


# Process an entire group.
# This function will change depending on the analysis to perform.
process_group = function(grp, outfile)
{
    msg("Processing group", grp[1, GROUP_INDEX])

    left_data = grp[grp$occ2 <= LEFT_RIGHT, ]
    left_fit = lm(flow2 ~ occ2 -1, left_data)

    middle_data = grp[(MIDDLE_LEFT <= grp$occ2) & (grp$occ2 < MIDDLE_RIGHT), ]
    middle_fit = lm(flow2 ~ occ2, middle_data)

    mid_coef = summary(middle_fit)$coefficients

    right_data = grp[RIGHT_LEFT <= grp$occ2, ]
    right_fit = lm(flow2 ~ I(occ2 - 1) - 1, right_data)

    # Part of the SQL could be generated from this.
    out = data.frame(station = grp[1, GROUP_INDEX]
        , n_total = nrow(grp)
        , n_middle = nrow(middle_data)
        , n_high = nrow(right_data)
        , left_slope = coef(left_fit)
        , left_slope_se = summary(left_fit)$coefficients[1, 2]
        , mid_intercept = mid_coef[1, 1]
        , mid_intercept_se = mid_coef[1, 2]
        , mid_slope = mid_coef[2, 1]
        , mid_slope_se = mid_coef[2, 2]
        , right_slope = coef(right_fit)
        , right_slope_se = summary(right_fit)$coefficients[1, 2]
        )
        
    write.table(out, outfile, col.names = FALSE, row.names = FALSE
                , sep = SEP)
}


# Main stream processing
############################################################

# Initialize the queue
#queue = read.table(stream_in, nrows = CHUNKSIZE, sep = SEP)
# We could generate these read.table calls based on the Hive table being
# transformed.
queue = read.table(stream_in, nrows = CHUNKSIZE, colClasses = colClasses
    , col.names = col.names, na.strings = "\\N")

msg("Entering main stream processing loop.")

while(TRUE) {
    while(multiple_groups(queue)) {
        # Pop the first group out of the queue
        nextgrp = queue[, GROUP_INDEX] == queue[1, GROUP_INDEX]
        working = queue[nextgrp, ]
        queue = queue[!nextgrp, ]

        # Would be good to log which groups work and fail.
        try(process_group(working, stream_out))
    }

    # Fill up the queue
    nextqueue = read.table(stream_in, nrows = CHUNKSIZE
        , colClasses = colClasses, col.names = col.names, na.strings = "\\N")
    if(nrow(nextqueue) == 0) {
        msg("Last group")
        try(process_group(queue, stream_out))
        break
    }
    queue = rbind(queue, nextqueue)
}

# I'm not sure if this will run or if Hive will stop execution when stdin
# and stdout are exhausted.
msg("END R SCRIPT")
