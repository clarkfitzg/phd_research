# Some basic data analysis code

# begin input code
############################################################

# Vectorized ops
iris = iris[iris$Sepal.Length < 7, ]
iris$lpw = log(iris$Petal.Width + 20)

# Requires grouping
logmeans = tapply(iris$lpw, iris$Species, mean)

# Uses a global variable
avg = mean(logmeans)
iris$lpw_std = iris$lpw - avg

############################################################
# end input code

# Restore the original
data("iris")



# begin transformed code
############################################################

# Split the data on the correct column initially, so it's ready for the
# tapply and we don't need to reshuffle later. Then we would distribute
# these groups on several parallel workers- I'm not doing that because it's
# a little involved and it would distract from the focus here.
split_iris = split(iris, iris$Species)

# Loop fusion. This will run in parallel on the groups and will just
# update split_iris without bringing it back to the manager.
split_iris = lapply(split_iris, function(x) {
    x = x[x$Sepal.Length < 7, ]
    x$lpw = log(x$Petal.Width + 20)
    x
})

# Run in parallel, return a scalar for each group back to manager.
logmeans = sapply(split_iris, function(x) mean(x$lpw))

# Same as original
avg = mean(logmeans)

# Again update split_iris in place without moving it. We would send the
# global variable 'avg' to all the workers.
split_iris = lapply(split_iris, function(x, .avg = avg) {
    x$lpw_std = x$lpw - .avg
    x
})

############################################################
# end transformed code
















# Just for kicks, how would I write this with data.table?

library(data.table)
data("iris")
iris = data.table(iris)


iris = iris[Sepal.Length < 7, ]

iris = iris[, lpw := log(Petal.Width + 20)]

logmeans = tapply(iris$lpw, iris$Species, mean)

# TODO: Come back here.
logmeans = iris[, mean(lpw), Species]

# Uses a global variable
avg = mean(logmeans)
iris$lpw_std = iris$lpw - avg
