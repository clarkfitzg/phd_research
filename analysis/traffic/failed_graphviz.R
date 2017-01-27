# This is nice, but labels should be visible
pdf("taskgraph.pdf", width = 20, height = 12)
# I'm sure this is changing something at least, since the shape can be
# changed.

gv_attrs = list(graph = list()
                , node = list(shape = "rectangle", fontsize = 20)
                , edge = list()
                )
plot(tg, attrs = gv_attrs)
dev.off()

# Wish I could use this, but no obvious way to coerce it into the right
# class object.
tg2 = DiagrammeR::create_graph(tg)
