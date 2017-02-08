
library(fda)

# fdobj functional data object
# h window
LongRun <- function(fdobj, h, basis, kerneltype = "bartlett"){
   
   N = ncol(fdobj$coefs)
   D = nrow(fdobj$coefs) 
   
   
   Kernel <- function(i, h) {
      x = i/h
      
      if (kerneltype == "flat") {
         return(1)
      }
      if (kerneltype == "simple") {
         return(0)
      }
      if (kerneltype == "bartlett") {
         return(1 - x)
      }
      
      if (kerneltype == "flat_top") {
         if (x < 0.1) {
            return(1)
         } else {
            if (x >= 0.1 & x < 1.1) {
               return(1.1 - x)
            } else {
               return(0)
            }
         }
      }
      
      if (kerneltype == "parzen") {
         if (x < 1/2) {
            return(1 - 6 * x^2 + 6 * abs(x)^3)
         } else {
            return(2 * (1 - abs(x))^3)
         }
      }
   }
   
   D_mat = matrix(0, D, D)
   
   fdobj_centered = center.fd(fdobj)
   
   # Long Run Cov Est
   for (k in 1:D) {
      for (r in k:D) {
         s = fdobj_centered$coefs[k, 1:N] %*% fdobj_centered$coefs[r, 1:N]
         if (h > 0) {
            for (i in 1:h) {
               a = fdobj_centered$coefs[k, 1:(N - i)] %*% fdobj_centered$coefs[r, 
                                                                               (i + 1):N]
               a = a + fdobj_centered$coefs[r, 1:(N - i)] %*% fdobj_centered$coefs[k, 
                                                                                   (i + 1):N]
               s = s + Kernel(i, h) * a
            }
         }
         
         D_mat[k, r] = s
         D_mat[r, k] = D_mat[k, r]
      }
   }
   
   D_mat = D_mat/N
   
   # compute eigenvalues of the coefficient matrix
   eigen_struct = eigen(D_mat, symmetric = TRUE)
   
   # compute eigenfunctions using the eigenvalues
   eigenfunc = fd(eigen_struct$vectors, basisobj = basis)
   
   # using abs(...) is an ad-hoc regularization solution
    list(ef = eigenfunc, ev = abs(eigen_struct$values), covm = D_mat)
}


