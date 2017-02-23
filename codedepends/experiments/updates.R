# An example of an update that may or may not happen.

a = 1
if(sample(c(TRUE, FALSE), 1)) a = a + 1
print(a)
