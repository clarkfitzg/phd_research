# Mon Mar  6 16:16:16 PST 2017
# Attempting to run the generated script using the event loop

source("../../eventloop.R")

# Has a problem finding x
script = CodeDepends::readScript("../traffic_sim2.R")
eventloop(script)


#script = CodeDepends::readScript("traffic_sim2_sorted.R")
#plot_index = c(47, 48)
#eventloop(script[-plot_index])
#for(i in plot_index){
#    eval(script[[i]])
#}
