
f = file("data.txt")

open(f, "rt")

read.table(f, sep = ",", nrow = 2)
