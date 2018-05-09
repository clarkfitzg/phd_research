library(autoparallel)

script = parse("script2.R")

tg = task_graph(script)

schedule = minimize_start_time(script, tg)

plot(schedule)

