# Wed May  1 16:25:14 PDT 2019
#
# Simulate and visualize how well different data splitting schemes might work in practice.
# Suppose that the programs are not IO bound.
# (Parallelism doesn't help for IO bound programs.)

# Split n into w approximately even groups
even_split = function(n, w)
{
    baseline = floor(n / w)
    extras = rep(0, w)
}

# Case 1- Laptop, 8 cores

ndata = 1000
nworkers = 8

# Case 2 - Peloton GPU (NVIDIA Geforce GTI 980 TI)
nworkers = 2816
clock_speed = 1 # GHz
