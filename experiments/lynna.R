# Mon May 28 08:31:37 PDT 2018

# Lynna Chu was doing large simulations on the department servers.
# Simulations are the most embarrassingly parallel things that exist, and
# she doesn't need any help with it.
#
# I'm interested to see if I can find task parallelism in the one function,
# getZL. The code works, but exposes a bug in my implementation. Come back
# and fix it.

p = autoparallel::autoparallel("getZL.R")
