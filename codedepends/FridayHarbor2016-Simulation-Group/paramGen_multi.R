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