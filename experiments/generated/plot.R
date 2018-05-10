library(autoparallel)

s4 = autoparallel("script4.R")

plot(s4$schedule)

# TODO: Transfers a variable twice
s5 = autoparallel("script5.R")
plot(s5$schedule)

s5 = autoparallel("script5.R", maxworkers = 3L)
plot(s5$schedule)

# Duncan's "revisit"
s7 = autoparallel("script7.R", maxworkers = 2L)
plot(s7$schedule)
