# Tue Apr 24 17:21:26 PDT 2018

# Checking for loop carried dependence

library(rstatic)
library(testthat)


no1 = quote_ast(ans[[i]] <- f(x[[i]]))
yes1 = quote_ast(theta <- update(theta))


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


loopbody = yes1

#' Returns TRUE if it finds a flow dependency in the loop body, and FALSE
#' otherwise.
flow_dep = function(loopbody, ivars = "i")
{

    # Would be nice to just do nothing when we call to_ast() on something
    # that's already an ast.
    if(!is(ast, "ASTNode")){
        ast = to_ast(loopbody)
    }

assigned_to = ast$write$basename

appears(assigned_to, ast$read)



}

flow_dep
