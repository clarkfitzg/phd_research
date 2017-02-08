############################################
#### DATA GENERATION FUNCTION (dataGen) ####
############################################

## RServ20161019

source('paramGen_multi.R')
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

