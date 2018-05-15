# Mon May 14 11:06:45 PDT 2018
#
# I need a way to accurately measure timings on a single run.

library(microbenchmark)


e = parse(text = '
          #.initialize_timer_throwaway = NULL
          x = x + 1
          y = x + 2
          z = y + 3
')

x = 0

# Expect x = 1, y = 2 after this
# Yes, that happens

out = microbenchmark(list = e, times = 1L
    , control = list(order = "inorder"))

class(out)
