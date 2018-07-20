itemrecovery <- function(...) { 
    list(...)	
}



myseed      <- sample.int(n = 1000000, size =3)
sample.size <- c(505, 1005, 2005)
test.length <- c(15, 30, 45) 
correlation <- c(0.0, 0.4, 0.8)
for (s in 1:length(sample.size)) { 
    for (t in 1:length(test.length)) { 
        for (k in 1:length(correlation)) {
            for (i in 1:length(myseed)){ 
                result[[i]] <- identity(sample.size = sample.size[s], nitem = 
                test.length[t],corr=correlation[k],seed = myseed[i])   
            }
        }
    }
}
