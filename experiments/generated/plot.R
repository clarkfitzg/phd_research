library(autoparallel)

script = parse("script5.R")
tg = task_graph(script)
schedule = minimize_start_time(script, tg, maxworkers = 3L)
plot(schedule)

autoparallel("script6.R", maxworkers = 3L)

script = parse("script6.R")
tg = task_graph(script)
schedule = minimize_start_time(script, tg, maxworkers = 2L)
plot(schedule)

