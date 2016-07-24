# Sun Jul 24 07:14:25 PDT 2016

# Answer this stack overflow question

library("SparkR")

sparkR.stop()
sc <- sparkR.init()
sqlContext <- sparkRSQL.init(sc)

x = c(1,2)
xDF_R = data.frame(x)
colnames(xDF_R) = c("number")
xDF_S = createDataFrame(sqlContext,xDF_R)
xDF_R$result = sapply(xDF_R$number, ppois, q=10)

wrapper = function(df){
    out = df
    out$result = sapply(df$number, ppois, q=10)
    return(out)
}
xDF_S2 = dapplyCollect(xDF_S, wrapper) 
identical(xDF_S2, xDF_R)

# But then it failed on the second time?
