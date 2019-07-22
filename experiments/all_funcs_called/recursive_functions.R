# Fri Jul 12 15:52:38 PDT 2019
#
# I would like an analysis that accepts a function call object, say `quote(f(x))`, and some environment, and recursively does the following:
#
# - Finds every function that is called on `x`.
# - Finds every R function that can possibly be called in the course of evaluating this function.
#
# When I say find, I mean the fully qualified name in a package, or the global function.
#
# It should do this only within the R level, not trying to go into the `.Primitive`, `.Call` C level interfaces.

library(CodeDepends)





# What's the difference between getExportedValue and get?
# getExportedValue does something with "lazydata"



# We should be able to use CodeDepends for this.


# The functions that came from a package, so they're non local 
get_pkg_funcs = function(info){
    out = names(info@functions)[!info@functions]
    out = out[!is.na(out)]
    # workaround for self-referential functions, see https://github.com/duncantl/CodeDepends/issues/41
    locally_defined = info@outputs
    setdiff(out, locally_defined)
}


# Extract all the functions found in a formal arguments
get_formal_funcs = function(p, ...)
{
    if(!missing(p) && is.call(p)){
        info = getInputs(p, ...)
        names(info@functions)
    }
}


skip = function(...) NULL


# recursively add the usage of all functions to the cache.
#
# @param fun_name, string naming a function
# @param cache, environment to store which functions have been used
# @param search_env, environment where to look up function
# @param ... arguments to CodeDepends::inputCollector
add_function_to_cache = function(fun_name, cache, search_env = environment(), ...)
{
    missing_func = FALSE
    tryCatch(fun <- get(fun_name, search_env), error = function(e) {
        missing_func <<- TRUE
    })

    if(missing_func){
        # The only way to get this function is to locally evaluate the call to `function` that creates it.
        # If we do that, we'll need to be much more careful about lexical scoping.

        message(sprintf("\nCannot find %s.\n", fun_name))
        
        # Add them to the cache anyways so that this function will work recursively.
        cache_name = paste("**LOCAL CLOSURE**", fun_name)
        cache[[cache_name]] = character()

        return()
    }

    fun_env = environment(fun)

    cache_name = if(is.null(fun_env)){
        # Primitives don't have environments
        fun_name
    } else if(isNamespace(fun_env)){
        paste0(getNamespaceName(fun_env), '::', fun_name)
    } else {
        # .libPaths() is evaluated with local()
        paste(capture.output(print(fun_env)), fun_name)
    }

    if(!exists(cache_name, cache)){
        message(paste("adding", cache_name))

        # .Internal calls use functions that don't exist at the R level,
        # so don't analyze any of the subexpressions inside them.
        col = inputCollector(.Internal = skip, ...)
        info = getInputs(fun, collector = col)

        formal_funcs = lapply(formals(fun), get_formal_funcs, collector = col)
        func_names = sapply(info, get_pkg_funcs)
        func_names = unique(unlist(c(formal_funcs, func_names)))

        cache[[cache_name]] = func_names

        for(fn in func_names){
            Recall(fn, cache, search_env = fun_env, ...)
        }
    }
    #if(fun_name == "default.stringsAsFactors") browser()
}

cache = new.env()


# What happens if I just grab the call to options when I see it?
# This is much like tracing the function
recorded_calls = new.env()
record_usage = function(e, ...)
{
    func_name = as.character(e[[1]])
    recorded_calls[[func_name]] <<- c(recorded_calls[[func_name]], e)
    CodeDepends::defaultFuncHandlers[["_default_"]](e, ...)
}


add_function_to_cache("data.frame", cache, getOption = record_usage, options = record_usage, stop = record_usage)

# Seems to work fine
recorded_calls[["stop"]]

recorded_calls[["options"]]
recorded_calls[["getOption"]]

# Nothing. 
# This means they do not find getOption("stringsAsFactors") in default.stringsAsFactors
# This is probably because we're not walking the code in the default parameters.
# Which means we're not walking the code in any of the default parameters, so we're potentially missing a whole lotta code.



# Wow, 495 different functions!
nc = names(cache)
length(nc)

# Nothing
grep("graphics", names(cache), value = TRUE)



if(FALSE){

# Looks like Duncan did the same thing in CodeDepends::makeCallGraph, but it only looks within the package.
cg_CodeDepends = makeCallGraph("package:CodeDepends")

cg_base = makeCallGraph("package:base")
# Doesn't work:
# Error in checkValidNodeName(nodes) :
#  node name(s) contain edge separator ‘|’: ‘|’, ‘|.hexmode’, ‘|.octmode’, ‘||’

}
