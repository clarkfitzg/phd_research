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


loop_body_to_func = function(loop)
{

    # Probably will end up using better tools to get these in here.
    names(loop) = c("for", "iter", "ivar", "body")

    f = function() NULL

    args = alist(ITER_VARIABLE = )
    names(args) = as.character(loop$iter)
    formals(f) = args

    body(f) = loop$body

    # Strip the environment
    environment(f) = globalenv()
    f
}


f7 = loop_body_to_func(l7)


# This doesn't find the variable `ans`.
findGlobals(f7, merge = FALSE)
