nworkers = 2
starting_port = 33000  # Random, just need it to be open.

# This is potentially a lot of sockets, could become a problem.

# PORTS[from, to] is where to open
PORTS = matrix(starting_port + seq(nworkers * nworkers)
                 , nrow = nworkers)


#' We won't necessarily create all connections, so some will be NULL.
close.NULL = function(...) NULL
