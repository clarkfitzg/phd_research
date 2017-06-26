# Mon Jun 26 11:22:02 PDT 2017
#
# Process all the PEMS data

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


allfiles = list.files("/scratch/clarkf/pems/TODO")

fds = parallel::mclapply(allfiles, function(x) try(process_one(x)))

save.image("fds.RData")
