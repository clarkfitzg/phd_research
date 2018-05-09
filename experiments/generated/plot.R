library(autoparallel)

script = parse("script5.R")
tg = task_graph(script)
schedule = minimize_start_time(script, tg, nprocs = 3L)
plot(schedule)

autoparallel("script5.R", maxworkers = 3L)

script = parse("script4.R")
tg = task_graph(script)
schedule = minimize_start_time(script, tg, nprocs = 2L)
plot(schedule)

