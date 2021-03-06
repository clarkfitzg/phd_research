# Tue Mar 13 17:14:18 PDT 2018
# Working through this thread: https://github.com/duncantl/RTypeInference/issues/5

library(RTypeInference)
library(typesys)

# Thu Mar 29 14:58:08 PDT 2018
#
# First let's try something basic. This is from 
# RTypeInference test_infer_dm

  node = rstatic::quote_cfg(
    function(x) {
      y = f(x)
      g(y)
    }
  )

  global_tenv = typesys::TypeEnvironment$new(
    "f" = a ~ a,
    "g" = Integer ~ Logical,
    quantify = TRUE
  )

  result = infer_dm(node, global_tenv)

  # -----
  expect_is(result@args[["x_1"]], "typesys::IntegerType")
  expect_is(result@return_type, "typesys::LogicalType")



############################################################


npbin = function(occupancy, flow, station)
{
    breaks = dyncut(occupancy)
    binned = cut(occupancy, breaks, right = FALSE)
    groups = split(flow, binned)

    out = data.frame(station = rep(station, length(groups))
        , right_end_occ = breaks[-1]
        , mean_flow = sapply(groups, mean)
        , sd_flow = sapply(groups, sd) 
        , number_observed = sapply(groups, length)
    )   
    out 
}


cfg = rstatic::to_cfg(npbin)

# How do I specify a list of numeric vectors?
# This doesn't work
ListType(list(NumericType()))


# This is me attempting to define type inference behavior for the
# functions used in npbin:

tenv = typesys::TypeEnvironment$new(
    dyncut = Numeric ~ Numeric
    , cut = c(Numeric, Numeric, Logical) ~ Integer
    #, split = Numeric ~ ListType()
    #, split = a ~ List(a)
    #, split = Numeric ~ Numeric
    , quantify = TRUE
    , mean = Numeric ~ Numeric
    , sd = Numeric ~ Numeric
    , length = x ~ Integer
)


infer_dm(cfg, tenv)


# Talking to Nick
# Thu Mar 29 17:01:17 PDT 2018

# Question: How to use vector? I want to say something like:
#    "dyncut" = NumericVector ~ NumericVector
#   But I notice part on vectors is commented out of vignette

# Ans: Changing to all vectors

# Question: How to use List? I want to express that `split` takes in a
# vector of type t and outputs a list of vectors of type t.

# Ans: Nick's working on lists now

# Feedback: Useful example in vignette would be:
#    "length" = x ~ Integer

# Feedback: I tend to think of the output / response as coming on the LHS of ~, so
#   I was writing it backwards initially.

# Feedback: The ~ notation is convenient, does it work for all possible
# types? When I try it with list I see something like:
#   Error in formula_to_type.name(x[[3]]) :  Unrecognized type 'List'.
# Would be nice something along the lines of:
#       Valid types include: Logical, Integer, etc.
