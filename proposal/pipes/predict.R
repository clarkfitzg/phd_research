source("readargs.R")

fX = file(INFILE)
fY = file(OUTFILE)
open(fX)
open(fY, "w")

while(N > 0){

    X_i = scan(fX, what = colclasses, nlines = CHUNKSIZE, quiet = TRUE)
    X_i = data.frame(X_i)
    y = predict(fit, X_i)
    cat(y, file = fY, sep = "\n")
    N = N - CHUNKSIZE

}

close(fX)
close(fY)
