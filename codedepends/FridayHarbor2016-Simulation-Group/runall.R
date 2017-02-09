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

# Clark: Manually replacing with script
#source('simulations.R')

## Simulations
library(MASS)
library(lme4)
options(scipen=999)
# B = # of simulations

simResults = function(B,M,I,...){
  args = list(...)
  `%ni%` <- Negate(`%in%`)
  l = list()
  #if(B<=1|S%ni%(1:nrow(M))) stop('B must be greater than 1, or Structure is not defined')

# Clark: Manually replacing with script
  #source('dataGen.R')

############################################
#### DATA GENERATION FUNCTION (dataGen) ####
############################################

## RServ20161019

# Clark: Manually replacing with script
#source('paramGen_multi.R')

#################################################
#### Parameter GENERATION FUNCTION (paramGen)####
#################################################

## RServ20161019

paramGen = function(I,A){
  library(MASS)
  ############################################
  ### SET PARAMETERS and INPUTS ###
  ############################################
  # Causal Structure scenarios
 simInputs = SInputs(A)
  #/*Notes for modifications:
  #1. To eliminate random intercept and random slope terms, set sigma_square_zeta0(s2z0)=0, sigma_square_zeta1(s2z1)=0, and sigma_zeta_01(sz01)=0.
  #2. To eliminate autoregressive covariance structure, set rho=0.
  #3. To eliminate measurement error, set sigma_square_delta(s2d)=0.
  

  trueB = simInputs$b11[I]+simInputs$h0[I]*simInputs$b13[I]
  SI = simInputs
  return(list(Scenario = simInputs$Scen[I],
              N = simInputs$N[I],
              n.obs = simInputs$n.obs[I],
              t.int = simInputs$t.int[I], 
              pexp = simInputs$pexp[I],
              p=simInputs$p[I],
              f.param = simInputs[I,c('b00','b01','b02','b03','b10','b11','b12','b13')],
              b.err = simInputs[I,c('s2z0','sz01','sz01','s2z1')],
              w.err = simInputs$s2e[I],a.err = simInputs$rho[I],m.err = simInputs$s2d[I],
              s.param = simInputs[I,c('g1','g2','g3','g4')],
              c.param = simInputs[I,c('h0','h.sd')],
              trueB = trueB,
              g.init = simInputs$g.init[I], SimInput = SI))
}
## Average g0 values from previous runs
df60 = c(-1.098328, -1.179162, -1.179204, -1.283768, -1.117660, -1.117924, -1.139949,
         -1.179109, -1.179059, -1.284322)
df75 = c(0.3601600, 0.4228043, 0.4229611, 0.5042439, 0.3956160, 0.3955560, 0.4366983,
         0.4230847, 0.4228011, 0.5041212)
df90 = c(3.250084, 3.471664, 3.470838, 3.790364, 3.313029, 3.313201, 3.420367, 3.471869,
         3.470895, 3.789709)
SInputs = function(A){
  survAge = list(Age = c(60,75,90), DeathP = c(.31,.65,.97), g.init = list(df60,df75,df90))
  data.frame(Scen = c(1,rep(2,3),rep(3,3),rep(4,3)), #scenMat row
                                   N = 100000,     # number of participants
                                   t.int = 1.5,  # time between observations
                                   n.obs = 7,    # number of observations
                                   pexp = .4,    # prevalence of low education
                                   p=with(data.frame(survAge[1],survAge[2]), DeathP[Age==A]), # probability of death for population
                                   #Variances and correlations
                                   s2z0 = 0.2,   # variance of random cognitive intercept
                                   s2z1 = 0.005, # variance of random cognitive slope
                                   sz01 = 0.01,  #  covariance of random intercept and random slope
                                   s2e = 0.70,   # variance of unexplained variation in Cij
                                   rho = 0,      # correlation between noise terms for Cij
                                   s2d = 0,      # variance of measurement error of Cij
                                   b00 = 0,      # cognitive intercept for unexposed
                                   b01 = -0.5,   # effect of exposure on cognitive intercept
                                   b02 = 0,      # effect of u1 on cognitive intercept
                                   b03 = 0,      # effect of U2 on cognitive intercept
                                   b10 = -0.05,                                                  #cognitive slope for unexposed
                                   b11 = c(rep(-0.0375,8),-0.0125,-0.0375),                      #effect of exposure on cognitive slope
                                   b12 = c(-0.025,rep(c(-0.025,-0.050,-0.025),2),rep(-0.025,3)), #effect of U1 on cognitive slope
                                   b13 = c(rep(-0.025,8),-0.075,-0.025),                         #effect of U2 on cognitive slope
                                   # Survival Probability Parameters
                                   g1 = c(rep(log(2),7),rep(log(sqrt(2)),2),log(2/sqrt(3))),
                                   g2 = c(0,rep(log(2),2),log(3),rep(0,6)),
                                   g3 = c(rep(0,7),rep(log(2),2),log(3)),
                                   g4 = c(rep(0,4),rep(log(2),2),log(3),rep(0,3)),
                                   # Education Effects
                                   h0 = .5,        #Effect of education to pathology (U1)
                                   h.sd = sqrt(1),  #sd of effect of education 
                                   g.init = if(A==60){unlist(survAge[[3]][1])}else{
                                            if(A==75){unlist(survAge[[3]][2])}else{
                                              unlist(survAge[[3]][3])}}# initial value for optimization to find g0
)}

dataGen = function(sMatrix = scenMat,I){
  param = paramGen(I,A)
  attach(param,warn.conflicts = FALSE)
  sV = sMatrix[Scenario,]
  t.beta = trueB
  ## Create data frame of population
  df = data.frame(id = 1:N) 
  # Step 1: Generate exposure variable with prevalence pexp by generating a U(0,1) distribution and setting exposure=0 if the random number<pexp, else exposure=1
  df$exposure = rbinom(N,1,pexp)
  # Step 2a: Generate U1, a continuous time-constant variable, U~N(0,1) genetic polygenic risk score*/ 
   df$U1 = rnorm(N,mean = 0,sd = 1)
   #df$U1 = scale(df$U1,center = TRUE, scale = TRUE) ## scale so we have mean zero, sd 1
   
   # Step 2b: Generate U2, a continuous time-constant variable, U~N(0,1) pathology variable*/
  # Effect of education to pathology, h0
   
   df$U2 = with(df,c.param$h0*exposure + rnorm(n = N,mean = 0,sd = c.param$h.sd))
   #df$U2 = scale(df$U2,center = TRUE, scale = TRUE) ## scale so we have mean zero, sd 1
   
   #Step 3: Generate probability of death before  60,75,90
   #Step 3a: Generate g0
   
   g0 = g.init
   #g0 = g0Gen(sV=sV,df = df,g = unname(unlist(s.param)),N=N,p = p, g.init = g.init)

  lin.pred = with(df,exp(g0+s.param[[1]]*exposure + s.param[[2]]*U1+ s.param[[3]]*U2 + s.param[[4]]*exposure*U1))
  df$p_surv65=with(df,lin.pred / (1+lin.pred))
  
  df$survU = unlist(lapply(1:N,function(i){ifelse(runif(1)<df$p_surv65[i],0,1)}))
  
  # Step 5: Generate random terms for slope and intercept, zeta_0i (z0i) and zeta_1i (z1i),where zeta_0i and zeta_1i covary*/
  Sig = matrix(unlist(b.err),nrow=2,ncol=2)
  df = data.frame(df,b = mvrnorm(N,mu = c(0,0),Sigma = Sig))
  
  ################################################################################
  # Step 6: Add time varying effects
  time = seq(0,t.int*(n.obs-1),t.int)
  df.long = df[rep(seq_len(nrow(df)), each=n.obs),]
  df.long$time = rep(time,N)
  
  df$alpha_ij = sqrt((1-a.err*a.err)*w.err)

  epsilon0 = rnorm(N,0,sqrt(w.err))
  autoerr = matrix(0,N*n.obs)
  df.long$autoerr = for(i in 1:N){
    autoerr[n.obs*(i-1)+1] = epsilon0[i]
    for(j in 2:(n.obs)){
      autoerr[n.obs*(i-1)+j] = a.err*autoerr[n.obs*(i-1)+j-1]+rnorm(1,0,sqrt((1-a.err*a.err)*w.err))
    }
  }
  #unlist(lapply(1:N,function(i){arima.sim(n = n.obs, list(ar = c(0.4, 0)),sd = w.err)})) # alternative way to calculate ar(1)
  
  # Step 7: Generate "true" and "measured" cognitive function at each wave,where measured cognitive function = true cognitive function + error*/
  #Cij = b00 + b01*exposurei + b02*U1 + b03*U2+ (b10 + b11*exposurei + b12*U1 + b13*U2)*timeij+ z0i +z1i*timeij + epsilonij*/
  # Generate true cognitive function*/
  
  df.long$true_cogfxn  = with(df.long, f.param[[1]] +f.param[[2]]*exposure + f.param[[3]]*U1 + f.param[[4]]*U2 +(f.param[[5]] + f.param[[6]]*exposure +f.param[[7]]*U1+f.param[[8]]*U2)*time + b.1 +b.2*time + autoerr)
  
  # Generate measured cognitive function (true cognitive function measured with error)*/
  # C_ij = C_ij + error_ij
  # First, generate delta term (delta_ij = measurement error for Cij) for each visit
  
  df.long$delta = rnorm(N*n.obs, 0,  sqrt(m.err))
  df.long$measured_cogfxn = with(df.long,true_cogfxn+delta)
  
  #Return Final Data
  r.list = list(df.long = df.long,g0 = g0,tB = t.beta)
  return(r.list)
}
#******************************************************************************/
#***  End data generation                          ***/
#/*
#CHECK : geeglm(autoerr~1,family = gaussian, data = df.long,id = id,corstr="ar1")
#*****************************************************************************/


g0Gen = function(sV,df,g,N,p,g.init){
  
  si = with(df,lapply(exposure,function(x){(1-x)*cbind(diag(1,nrow = length(sV)/2),matrix(0,nrow = length(sV)/2,ncol = length(sV)/2))+
      (x)*cbind(matrix(0,nrow = length(sV)/2,ncol = length(sV)/2),diag(1,nrow = length(sV)/2))}))
  siS = with(df,list(lapply(si,function(x){t(x%*%sV)}),exposure,U1,U2))
  siS1 = lapply(1:N,function(x){list(siS[[1]][x],siS[[2]][x],siS[[3]][x],siS[[4]][x])})
  f1 =function(g0){
    p.i  = unlist(lapply(siS1,function(x){
      ux = unlist(x)
      e = ux[5]
      u1 = ux[6]
      u2 = ux[7]
      lp = unname(unlist(g0+ux[1]*g[1]*e+ux[2]*g[2]*u1+ux[3]*g[3]*u2+ux[4]*g[4]*e*u1))
      exp(lp)/(1+exp(lp))
    }))
  }
  f2 = function(g0){(sum(f1(g0))-N*p)^2}
  
  g0op = optim(g.init,f2,method="BFGS")
  g0op$par
}

  simSum = data.frame(t(sapply(1:B,function(b){
     dG = dataGen(M,I)
     g.sim = dG$g0
     tB = dG$tB
     df.long = dG$df.long
     df = df.long[!duplicated(df.long$id),]
     dGS = subset(df,survU==1)
     samp2000 = sample(dGS$id,2000,replace = FALSE)
     df2000 = subset(df.long,id%in%samp2000)
     df2000U = df2000[!duplicated(df2000$id),]
     educ = subset(df2000U,exposure==0)
     noneduc = subset(df2000U,exposure==1)
  f1 = lmer(measured_cogfxn~exposure*time+(time|id),data = df2000)
  #f1 = lmer(measured_cogfxn~exposure*time+(time|id),data = df.long)
  df.sum = data.frame(IScen = I,tB, g.sim,N,sum(df2000U$survU),nrow(df2000)/nrow(df2000U),sum(df2000U$exposure),round(sum(df$survU)/N*100,2),
                      U1TotEduc = mean(subset(df2000U,exposure==0)$U1),U1TotNonEduc = mean(subset(df2000U,exposure==1)$U1),
                      U1SurvEduc = mean(educ$U1),U1SurvNonEduc = mean(noneduc$U1),
                      U2TotEduc = mean(subset(df2000U,exposure==0)$U2),U2TotNonEduc = mean(subset(df2000U,exposure==1)$U2),
                      U2SurvEduc = mean(educ$U2),U2SurvNonEduc = mean(noneduc$U2),
                      t(fixef(f1)),t(diag(vcov(f1))^.5))
  }
  )))
  tB1 = unlist(unique(simSum$tB))
  simSum = data.frame(apply(simSum,2,unlist))
  colnames(simSum) = c('IScen','trueB1','g0','N','SurvN','n.obs',"LowEducN","SurvPerc",
                       'U1TotEduc','U1TotNonEduc','U1SurvEduc','U1SurvNonEduc',
                       'U2TotEduc','U2TotNonEduc','U2SurvEduc','U2SurvNonEduc',
                       'Int','Educ','Slope','Educ.Slope','sd.I','sd.EI','sd.time','sd.ET')
  
  #####################################
  ### Calculate 95% CI and Coverage ###
  #####################################
  
  U_CI = mapply(function(x,y){x+1.96*y},x = simSum[,c('Int','Educ','Slope','Educ.Slope')],y = simSum[,c('sd.I','sd.EI','sd.time','sd.ET')])
  colnames(U_CI) = lapply(colnames(U_CI),function(x){paste(x,"U.CI")})
  
  L_CI = mapply(function(x,y){x-1.96*y},x = simSum[,c('Int','Educ','Slope','Educ.Slope')],y = simSum[,c('sd.I','sd.EI','sd.time','sd.ET')])
  colnames(L_CI) = lapply(colnames(L_CI),function(x){paste(x,"L.CI")})
  
  R1 = data.frame(simSum,U_CI,L_CI)
  R1$coverage = with(R1,mapply(function(x,y){ifelse(tB1<x&tB1>y,1,0)},x = Educ.Slope.U.CI,y = Educ.Slope.L.CI ))
  
  results = round(matrix(apply(R1[,c('Int','Educ','Slope','Educ.Slope','sd.I','sd.EI','sd.time','sd.ET')],2,mean),ncol = 2),6)
  results= cbind(results,apply(R1[,c('Int','Educ','Slope','Educ.Slope')],2,sd))
  
  rownames(results) = c('Int','Educ','Slope','Educ.Slope')
  colnames(results) = c('Beta_Avg','Est.SE','Emp.SE')
  res.df = data.frame(results)
  CovPerc = sum(R1$coverage)/B
  BiasPerc = (mean(R1$Educ.Slope)-tB1)/tB1
  RMSE = sqrt((res.df$Beta_Avg[4] - tB1)^2 + res.df$Emp.SE[4]^2)
  fullresults = list(data = R1,result=res.df,CovPerc = CovPerc,BiasPerc = BiasPerc, RMSE = RMSE)
  
return(fullresults)

}

writeResults = function(B,M = scenMat,I){
  r1 = simResults(B,M,I)
  saveRDS(r1,file = paste0('results',I,'.RDA',sep = ''))}

sapply(1:10,function(x){writeResults(B = 3, M = scenMat, I = x )})

r10 = readRDS('results10.RDA')
r5 = readRDS('results8.RDA')
View(r5$data)
View(r10$data)
