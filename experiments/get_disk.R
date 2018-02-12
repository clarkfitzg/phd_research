

disk_globals = environment()

disk_globals$x = 100

# Fails
x + 2

# Works
eval(x + 2, disk_globals)

# Can we actually put it on the disk?
# I want something like Python's @property that makes a method call look
# like an attribute. Only this should replace the symbol lookup with
# reading the object on disk.
#
# Actually I think it makes more sense to preprocess the script, then I can
# inject the code where I need it and I don't need to use eval().
