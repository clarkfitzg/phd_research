# Tue Jun 18 11:05:54 PDT 2019
#
# What if I just try to reimplement everything in makeParallel with rstatic?
# That almost feels easier.
# No, I shouldn't do it though.

# My goal is to get some minimal working examples of makeParallel actually accelerating a script, and I am struggling.
# What does the system need to do?

# 1. Identify function calls that are vectorized in large objects.
# 2. Gather the largest possible collections of vectorized function calls that it can.
# 3. Evaluate these collections of calls on one worker.
