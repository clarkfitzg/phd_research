# Mon Jun 26 11:22:02 PDT 2017
#
# Process all the PEMS data
#
# First version took 63 minutes to run on 20 cores. No optimization was done.
# Note that this is almost the same amount of time spent reading and
# splitting the data in the first place.
#
# First optimization would be to store the grouped data more efficiently,
# for example in a fast columnar binary format.
# Second optimization is an early out for fd_rlm if all the
# observations are zero or NA.

fd_rlm = function(flow, occupancy, cutoff = 0.15, ...)
{

    congested = occupancy > cutoff

    high = MASS::rlm(flow[congested] ~ occupancy[congested], ...)
    low = MASS::rlm(flow[!congested] ~ occupancy[!congested], ...)

    list(high_occcupancy = coef(summary(high))
         , low_occupancy = coef(summary(low))
         )
}


process_one = function(station_filename)
{
    # Row names are a problem
    station = read.csv(station_filename, row.names = NULL)[, -1]
    list(station_filename, fd_rlm(station$flow2, station$occupancy2))
}


allfiles = list.files("/scratch/clarkf/pems/stationID", full.names = TRUE)

fds = parallel::mclapply(allfiles, function(x) try(process_one(x)),
                         mc.cores = 20L)

save.image("fds.RData")


# About half resulted in some kind of error.
errors = sapply(fds, is, "try-error")
