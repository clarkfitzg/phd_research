# Tue Feb 14 10:50:32 PST 2017
#
# How does R represent code after parsing?
#
# What will be the top level nodes?
# Ans: This has 4 top level nodes corresponding to 
# the block, the function, and the two z assignments

# This is a language object of length 3. The first element is `{`, the
# other two are the two lines.
{
    a = 10
    b = 20
}

f = function(x)
{
    y = x + 5
    y * x
}

z1 = 100
z2 = 200
