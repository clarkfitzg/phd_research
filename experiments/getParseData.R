ex = parse(text = "
           # Hey dude
           a <- 10
           b <- a + 5
           plot(a)
")

# Two expressions here

p = getParseData(ex)

symbols = p[p$token == "SYMBOL", "text"]

p[p$token == "SYMBOL", ]

# So how can we tell if assignment is happening?
# It should be on the LHS of the equal sign...
# Looks like this returned parse tree is in order. So we can potentially
# use this to see which symbols are assigned to.
