library(autoparallel)

script = parse("script3.R")

tg = task_graph(script)

schedule = minimize_start_time(script, tg, nprocs = 3L)

plot(schedule)

