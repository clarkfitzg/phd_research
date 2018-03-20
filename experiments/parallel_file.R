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

# If the worker can write then I should see a file test.txt containing:
# worker
# manager

f = file("test.txt", "w")

# When I don't flush the output then I don't see "worker"
parallel::mcparallel(writeLines("worker", f))

# If I do flush the output then I do see "worker"
parallel::mcparallel({
    writeLines("worker", f)
    flush(f)  # close(f) will also flush
})

parallel::mccollect()
writeLines("manager", f)

# If I check the file without closing or flushing either of them it's
# empty. Then when I q() from the manager the file contains "manager". This
# means that the files are flushed in the background when terminating an R process
# with q() BUT NOT when terminating an R process as in `mcparallel`.
close(f)

# How about for reading?

write.table(letters, "letters.txt")
f = file("letters.txt", "r")
first = read.table(f, nrows = 5)

parallel::mcparallel(read.table(f, nrows = 5))

out = parallel::mccollect()
second = out[[1]]
third = read.table(f, nrows = 5)

# second is the same as third. This means the worker process only changed
# the state of the forked connection.
