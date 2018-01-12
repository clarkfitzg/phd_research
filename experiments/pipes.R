# Thu Jan 11 16:36:42 PST 2018
#
# A little experiment. What does command line piping give us?

p = 26
n = 1e7

# The columns we will read in
cols = c(5, 10, 15)

data = matrix(sample.int(n * p), ncol = p)

tempfile = "temp.txt"

write.table(data, tempfile)

keepers = rep("NULL", p)
keepers[cols] = "integer"

t2 = system.time(data2 <- read.table(tempfile, colClasses = keepers, nrows = n+1, skip = 1))

#shellout = pipe("cut -d ' ' -f 5,10,15 temp.txt | head")
shellout = pipe("cut -d ' ' -f 5,10,15 temp.txt")

t3 = system.time(data3 <- read.table(shellout, colClasses = rep("integer", length(cols)), skip = 1))

# We see a speed increase by a factor of:
120 / 18.5
# Therefore this is a valuable technique.

unlink(tempfile)
