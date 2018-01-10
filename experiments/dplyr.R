library(dplyr)

iris %>%
    group_by(Species) %>%
    do(head(.)) ->
    x

ex = parse(text = "iris %>% group_by(Species) %>% do(head(.))")[[1]]

ex[[1]]
