# Return the rightmost argument that actually exists
phi = function(...)
{
    call = sys.call()
    for(arg in seq(from = length(call), to = 2)){
        argname = as.character(call[[arg]])
        try(
            return(get(argname))
        , silent = TRUE)
    }
    stop("No arguments are defined!")
}


if(TRUE)
{

x1 = 10
x2 = 20
x3 = phi(x1, x2)

stopifnot(identical(x2, x3))

x4 = 30
x6 = phi(x4, x5)
stopifnot(identical(x4, x6))

x7 = 40
x8 = 50
x10 = 60
x11 = phi(x7, x8, x9, x10)
stopifnot(identical(x11, x10))

}
