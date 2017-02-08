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
  source('dataGen.R')
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

