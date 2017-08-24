# Thu Aug 24 11:08:54 PDT 2017
#
# Does R deep copy list arguments?
# NO

f = function(x){
    x[[1]] = 1
    x
}

# Working on an 8 GB machine
memory_use = function(){
    system(paste0("ps -p ", Sys.getpid(), " -o %mem"))
}

# 0.6 %
memory_use()

# A list containing an object around 1 GB.
gb = numeric(1e9 / 8)

# Process memory use should now be > 12 %
memory_use()
# Correct

l = list(100, gb)

# If process mem use remains around 12% then arg wasn't deeply copied.
# I am not sure if it will deeply copy. It certainly doesn't need to, and I
# wouldn't expect it to do so for an environment.
memory_use()
# No copy is made.

l2 = f(l)

memory_use()
# No copy is made. Good for performance!

l2[[2]][1] = 20

memory_use()
# Assignment makes a copy, as expected.
