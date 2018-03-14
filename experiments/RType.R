# Tue Mar 13 17:14:18 PDT 2018
# Working through this thread: https://github.com/duncantl/RTypeInference/issues/5

library(RTypeInference)

dyncut = function(x, ...) c(-Inf, 0, Inf)

npbin = function(x)
{
    breaks = dyncut(x$occupancy2, pts_per_bin = 200)
    binned = cut(x$occupancy2, breaks, right = FALSE)
    groups = split(x$flow2, binned)

    out = data.frame(station = rep(x[1, "station"], length(groups))
        , right_end_occ = breaks[-1]
        , mean_flow = sapply(groups, mean)
        , sd_flow = sapply(groups, sd) 
        , number_observed = sapply(groups, length)
    )   
    out 
}


cfg = rstatic::to_cfg(npbin)

cons = constrain(cfg)

infer_dm(cfg)
