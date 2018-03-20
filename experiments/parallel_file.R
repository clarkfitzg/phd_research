# Tue Mar 20 09:51:59 PDT 2018
#
# What happens when we pass open connections to a worker process?
#
# I remember Matt Espe attempting to operate on XML objects in parallel.
# It didn't work. From R's perspective the XML objects are C level
# pointers. What happens when they are serialized? It certainly won't work
# to save and then load them in another session, because when the process
# exits the OS frees that memory, so the pointer address won't be valid
# when it's loaded again.
#
# A UNIX fork provides "copy on write" access to the R objects in the
# manager process. Connections differ from other R objects because
# they maintain state. If we change that state in another process
# what happens?

# If this works then I should see a file test.txt containing:
# worker
# manager

f = file("test.txt", "w")
parallel::mcparallel(writeLines("worker", f))
parallel::mccollect()
writeLines("manager", f)
close(f)

# I only saw the lines written by the manager. So they don't actually
# share the connection.
