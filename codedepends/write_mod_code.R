source("helpers.R")

fname = "simple3.R"

s = readScript(fname)

# Can I cat this right back into a file now?

# It's just a list
selectSuperClasses("Script")

# Of language objects
typeof(s[[1]])

# Maybe just hijack the print method?
print(s[[1]])

tg = makeTaskGraph(fname)

tg2 = makeTaskGraph2(fname)

nodes(tg2)

# FINALLY figured out how to change the fontsize. Ack.
png("code_graph.png", width = 1080, height = 1500)

plot_big(tg2)

dev.off()


# Another thing to do here is to just use a table mapping integers to
# expressions
#expr_int = data.frame(int = as.character(seq_along(frags)))
#expr_int$expr = as(frags, "list")
