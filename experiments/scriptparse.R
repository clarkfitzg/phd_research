# Thu Feb  9 17:07:09 PST 2017
# Does R parse the whole script first?
# No, because we see the top line execute, and then it fails.

# But we can force it to parse the whole thing as a block by putting it all
# inside braces.

#{
print("Hey")

# Wrong syntax, needs comma
print(c("Hey" "Dude"))
#}
