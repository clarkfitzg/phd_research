### Result Summary ###
#setwd("~/Documents/FH2016/R_Folder_Server")
#library(dplyr)
#library(plotly)
#setwd("~/Documents/FH2016/RServ20161019")
## Scenarios (scenMat) refers to which predictors will affect probablity of death (survival) to age 60, 75, 90.
## There are four possibilities for both the Non-Exposed (High Education) and Exposed (Low Education) group
## Education, U1, U2, U2*Education
## The first four entries turn on covariates for the Non-Exposed, the second four, for the Exposed
# S1: education only, S2: Educ and U1, S3: Educ and U2, S4: Educ, U2, Educ*U2
# Entries (1,5) indicated effect of education
# Entries (2,6) are U1, (3,7) U2, (4,8) U2*Educ
S1 = c(0,0,0,0,1,0,0,0)
S2 = c(0,1,0,0,1,1,0,0)
S3 = c(0,0,0,0,1,0,0,1)
S4 = c(0,0,1,0,1,0,1,0)
S5 = c(0,0,1,0,1,0,1,1)

scenMat = rbind(S1,S2,S3,S4,S5)

## I indicates different parameters levels for survival effects as well as fixed effects on cognition. 
## See documenation for I in 1:10. 
#set.seed(082173)
A = 90
source('simulations.R')
writeResults = function(B,M = scenMat,I){
  r1 = simResults(B,M,I)
  saveRDS(r1,file = paste0('results',I,'.RDA',sep = ''))}

sapply(1:10,function(x){writeResults(B = 3, M = scenMat, I = x )})

r10 = readRDS('results10.RDA')
r5 = readRDS('results8.RDA')
View(r5$data)
View(r10$data)
