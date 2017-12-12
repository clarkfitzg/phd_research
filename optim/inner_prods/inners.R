# This is starting to remind me of the structure of knitr chunks...

{meta = list(node = 1
, description = "source functions"
)

# Construct a symmetric matrix from a "tall" data frame 
sym_matrix = function(df, i_ind = df[, "i"], j_ind = df[, "j"], val = df[, "fij"])
{
    N = max(i_ind, j_ind)
    out = matrix(NA, nrow = N, ncol = N)

    for(k in seq_along(i_ind)) {
        i = i_ind[k]
        j = j_ind[k]
        val_ij = val[k]
        out[i, j] = val_ij
        out[j, i] = val_ij
    }
    out
}

# Given observations of linear functions f and g at points a and b this
# calculates the integral of f * g from a to b.
#
# Looks like it will already work as a vectorized function. Sweet!
inner_one_piece = function(a, b, fa, fb, ga, gb)
{
    # Roughly following my notes
    fslope = (fb - fa) / (b - a)
    gslope = (gb - ga) / (b - a)

    fint = fa - fslope * a
    gint = ga - gslope * a

    # polynomial coefficients for integral
    p3 = fslope * gslope / 3
    p2 = (fint * gslope + fslope * gint) / 2
    p1 = fint * gint

    (p3*b^3 + p2*b^2 + p1*b) - (p3*a^3 + p2*a^2 + p1*a)
}


# Compute function inner product on two piecewise linear functions
#
# x1, y1 are vectors of corresponding x and y coordinates that define a
# piecewise linear function on [0, 1].
# Same for x2, y2.
piecewise_inner = function(x1, y1, x2, y2)
{
    x = sort(unique(c(x1, x2)))
    f = approx(x1, y1, xout = x)$y
    g = approx(x2, y2, xout = x)$y

    nm1 = length(x) - 1
    parts = rep(NA, nm1)

    # If inner_one_piece is vectorized then we can replace the for loop
    # with:
    a = -length(x)
    b = -1
    parts = inner_one_piece(x[a], x[b], f[a], f[b], g[a], g[b])
#    for(i in seq(nm1)){
#        ip1 = i + 1
#        parts[i] = inner_one_piece(x[i], x[ip1], f[i], f[ip1], g[i], g[ip1])
#    }
    sum(parts)
}


inner = function(s1, s2)
{
    piecewise_inner(x1 = c(0, s1$right_end_occ)
                    , y1 = c(0, s1$mean_flow) 
                    , x2 = c(0, s2$right_end_occ) 
                    , y2 = c(0, s2$mean_flow) 
                    )
}

}
############################################################
{meta = list(node = 2
, description = "read in data, verify that functions work"
)

fd_shape = read.table("~/projects/pems_fd/data/fd_shape.tsv"
    , col.names = c("station", "right_end_occ", "mean_flow", "sd_flow", "number_observed")
    , colClasses = c("integer", "numeric", "numeric", "numeric", "integer")
    , na.strings = "NULL"
    )

# Making this harder than it has to be...
keep = read.csv("~/projects/pems_fd/data/keep.csv")[, 1]
stn = split(fd_shape, fd_shape$station)
keep_logical = sapply(stn, function(x) all(x$station %in% keep))
stn = stn[keep_logical]
N = length(stn)

if(FALSE){
    # Just playing around interactively

    stn = head(stn)

}


# Works
inner(stn[[1]], stn[[2]])

# Doesn't work :(
# fd_inners <- outer(stn, stn, inner)

}
############################################################
{meta = list(node = 3
, nodetype = "serial"
, description = "big expensive computation"
)

fd_inners = matrix(NA, nrow = N, ncol = N)

# Takes 15 minutes. Numerical integration took 2+ hours with the three
# lines.
# Using a vectorized version on 1378 takes 4.1 minutes. Still slow.
# This profiling might be a good exercise for the reading group.
Rprof("serial.out")
# Spends 99% of time inside inner, as expected
time_serial = system.time(
for(i in 1:N){
    for(j in i:N){
        fij = inner(stn[[i]], stn[[j]])
        fd_inners[i, j] = fij
        fd_inners[j, i] = fij
    }
}
)
Rprof()

colnames(fd_inners) = rownames(fd_inners) = keep

}
############################################################
{meta = list(node = 3
, nodetype = "fork"
, description = "big expensive computation"
)

ij = combn(N, 2, simplify = FALSE)
ij = c(ij, lapply(seq(N), function(x) c(x, x)))
# Much uglier than the nested for loop...
# Which gives me an idea for doing something along the lines of foreach.
# We could first compute the loop indices and transform into an efficient
# parallel apply. This actually goes along with the CodeAnalysis.

do_ij2 = function(ij){
    i = ij[1]
    j = ij[2]
    fij = inner(stn[[i]], stn[[j]])
    c(i = i, j = j, fij = fij)
}

# This should be the one expensive line. Takes 8.8 minutes. This is more
# than twice as long as it took for the for loop. So far I've checked:
# - They get the same answer
# - I'm not inadvertently looping over twice as much data
# Structure of the computation:
# do_ij wraps inner, inner wraps piecewise_inner. piecewise_inner does a
# few things, most notably calling inner_one_piece. Hence I expect almost
# all the time to be spent inside piecewise_inner. Yet in the profile I see
# it only spends 57% of time in inner and piecewise_inner, compared to 99%
# with the for loop version.
Rprof("Rprof2.out")
time_parallel2 = system.time(
tall <- lapply(ij, do_ij2)
)
Rprof(NULL)

summaryRprof("Rprof2.out")

Rprof("Rprof3.out")
time_for = system.time({
    # Essentially just rewriting lapply
    out = vector("list", length = length(ij))
    for(i in seq_along(ij)){
        x = ij[[i]]
        out[[i]] = do_ij2(x)
    }
})
Rprof(NULL)

summaryRprof("Rprof3.out")



tall = do.call(rbind, tall)

fd_inners = sym_matrix(tall)

colnames(fd_inners) = rownames(fd_inners) = keep


}
############################################################
{meta = list(node = 4
, description = "post processing and save"
)

fd_inners_scaled = cov2cor(fd_inners)

save(fd_inners_scaled, file = "fd_inners_scaled.rds")

}
