# Fri Apr 27 13:06:17 PDT 2018
#
# 

library(codetools)

l7 = quote(
for(i in x) {
    tmp1 = f1(i)
    tmp2 = f2(i)
    ans[i] = g(tmp1, tmp2)
})

findLocals(l7)


# Will end up using better tools to get these in here.
nameloop = function(loop){
    names(loop) = c("for", "iter", "ivar", "body")
    loop
}


loop_body_to_func = function(loop)
{
    f = function() NULL

    args = alist(ITER_VARIABLE = )
    names(args) = as.character(loop$iter)
    formals(f) = args

    body(f) = loop$body

    # Strip the environment
    environment(f) = globalenv()
    f
}


# This might actually work with a shared object like a bigmemory matrix
loop_to_lapply_local_assign = function(loop)
{
    func = loop_body_to_func(loop)

    call("lapply", loop$ivar, func)
}



l7 = nameloop(l7)

f7 = loop_body_to_func(l7)

la7 = loop_to_lapply_without_assign(l7)


# This doesn't find the variable `ans`.
findGlobals(f7, merge = FALSE)
