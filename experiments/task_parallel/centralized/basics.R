source("utils.R")


# Can't do more than 1 slave on my 2 core machine!
mpi.spawn.Rslaves(nslaves = 2)

# From docs:
# ‘mpi.bcast.Rfun2slave’ transmits all master's functions to slaves and
# returns no value. 
mpi.bcast.Rfun2slave()

mpi.remote.exec(ls())
# The worker now has the functions in utils

script = parse(text = "
    datadir <- '~/data'            # A worker 1
    x <- paste0(datadir, 'x.csv')  # B worker 1
    y <- paste0(datadir, 'y.csv')  # C worker 2
    xy <- paste0(x, y)             # D worker 1
    print('all done')              # E worker 2
")


# Now we can write the actual program.
############################################################

evaluate(1, script[[1]])

# After I execute this command CPU usage on one slave process jumps to 100%
transfer("datadir", source = 1, dest = 2, tag = 12834)

evaluate(1, script[[2]])

evaluate(2, script[[3]])

transfer("y", source = 2, dest = 1, tag = 24789)

evaluate(1, script[[4]])

evaluate(2, script[[5]])


# Somehow I got a race condition. And it looks like zombies.
mpi.remote.exec(ls())



# Cleanup
############################################################
mpi.close.Rslaves()
