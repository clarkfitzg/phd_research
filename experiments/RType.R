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

tenv = typesys::TypeEnvironment$new(
    dyncut = Numeric ~ Numeric
    , cut = c(Numeric, Numeric, Logical) ~ Integer
    , split = x ~ ListType
    , quantify = TRUE
)


infer_dm(cfg, tenv)


# For Nick:

# 1. Question: How to use vector? I want to say something like:
#    "dyncut" = NumericVector ~ NumericVector
#   But I notice part on vectors is commented out of vignette

# 2. Feedback: Useful example in vignette would be:
#    "length" = x ~ Integer

# 3. Feedback: I tend to think of the output as coming on the LHS of ~, so
#   I was writing it backwards initially.

# 4. Feedback (low priority): 
#   Error in formula_to_type.name(x[[3]]) :  Unrecognized type 'List'.
#   Would be nice something along the lines of:
#       Valid types include: Logical, Integer, etc.


