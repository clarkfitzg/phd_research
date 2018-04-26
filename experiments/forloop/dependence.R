# Tue Apr 24 17:21:26 PDT 2018

# Checking for loop carried dependence

library(rstatic)
library(testthat)


no1 = quote_ast(ans[[i]] <- f(x[[i]]))
no2 = quote_ast({
    # Reads and writes a local variable
    fi = f(i)
    print(fi)
})
yes1 = quote_ast(theta <- update(theta))
yes2 = quote_ast({tmp <- update(theta)
    theta <- tmp})$body


#' Returns TRUE if varname is used in children of ast, and FALSE otherwise
appears = function(varname, ast)
{
    found = FALSE
    finder = function(node){
        if(is(node, "Symbol")){
            if(node$basename == varname)
                found <<- TRUE
        }
    }
    astTraverse(ast, finder)
    found
}


expect_true(
    appears("x", no1$read)
)

expect_false(
    appears("x", no1$write)
)


# Not using too much of rstatic here- it wouldn't be a big deal to write my
# own.

#' Returns a character vector of all unique symbols used in children of ast
findvars = function(ast)
{
    found = character()
    finder = function(node){
        if(is(node, "Symbol")){
            found <<- c(found, node$basename)
        }
    }
    astTraverse(ast, finder)
    sort(unique(found))
}




expect_equal(c("[[", "f", "i", "x"), findvars(no1$read$args[[3]]))


#' Returns TRUE if it finds a flow dependency in the loop body, and FALSE
#' otherwise.
flow_dep = function(loopbody, ivars = "i")
{
    # Single statements
    if(is(loopbody, "ASTNode"))
        loopbody = list(loopbody)

    reads = character()
    writes = character()
}


expect_false(flow_dep(no1))
expect_false(flow_dep(no2))
expect_true(flow_dep(yes1))
expect_true(flow_dep(yes2))

