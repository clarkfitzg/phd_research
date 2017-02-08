
# fdata: needs to be fdata object (functional data)

#------------------------
# Aston - Kirch (using Long Run Cov)

k.star = function(fdata, d, h, basis){
   n = ncol(fdata$coef)
   # estimate Long Run Cov Kernel for projection
   LongRunCov = LongRun(fdata, h=h, basis=basis)
   
   #Project the data
   eta.hat = inprod(fdata, LongRunCov$ef[1:d]) 
   eta.bar = colMeans(eta.hat)
   SIGMA = LongRunCov$covm[1:d, 1:d]
   
   S_n = function(k){
      Sn = matrix(0, d, k)
      for (i in 1:k){
         Sn[ ,i] = eta.hat[i, ] - eta.bar
      }
      rowSums(Sn)
   }
   
   val = sapply(1:n, function(k) t(S_n(k))%*%solve(SIGMA)%*%S_n(k))
   which.max(val)
}


#------------------------
# PCA

k.star1 = function(data, d){
   D = dim(data$coef)[1]
   n = dim(data$coef)[2]
   
   Fpca=pca.fd(data, nharm=D, centerfns=TRUE)
   eta = Fpca$scores[,1:d]
   Sigma = matrix(0,d,d)
   for (i in 1:d){
      Sigma[i,i] = Fpca$values[i]
   }
   
   if (d==1){
      Kappa = function(k){ 
         if (k==1){
            eta[1]-mean(eta)
         } else {
            sum(eta[1:k])-k*mean(eta)
         }
      }
   } else {
      Kappa = function(k){ 
         if (k==1){
            eta[1,]-colMeans(eta)
         } else {
            colSums(eta[1:k,])-k*colMeans(eta)
         }
      }
   }
   
   Q = function(k){
      1/n*t(Kappa(k))%*%solve(Sigma)%*%Kappa(k)
   }
   
   val = sapply(1:n, function(k) Q(k))
   return(which.max(val))
}


#fully functional (faster)
k.star2 = function(fdata){
   samp = fdata$coefs
   N = ncol(samp)
   Sn=(1:N)
   Sn[1]=0
   for(j in (2:N)){
      Sn[j]= sum((rowSums(samp[,1:j]) - (j/N)*rowSums(samp[,1:N]))^2)
   }
   min(which(Sn==max(Sn)))
}
