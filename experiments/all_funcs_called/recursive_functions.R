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


skip = function(...) NULL


# recursively add the usage of all functions to the cache.
add_function_to_cache = function(fun_name, cache, search_env = environment())
{
    missing_func = FALSE
    tryCatch(fun <- get(fun_name, search_env), error = function(e) {
        missing_func <<- TRUE
    })

    if(missing_func){
        # The only way to get this function is to locally evaluate the call to `function` that creates it.
        # If we do that we'll need to be much more careful about lexical scoping.

        message(sprintf("\nCannot find %s.\n", fun_name))
        empty = character()
        
        # Add them to the cache anyways so that this function will work recursively.
        cache_name = paste("**LOCAL CLOSURE**", fun_name)
        cache[[cache_name]] = empty
        return(empty)
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
        col = inputCollector(.Internal = skip)
        info = getInputs(fun, collector = col)

        func_names = sapply(info, get_pkg_funcs)

        func_names = unique(do.call(c, func_names))

        all_funcs_used = vector(length(func_names), mode = "list")

        for(i in seq_along(func_names)){
            all_funcs_used[[i]] = Recall(func_names[i], cache, search_env = fun_env)
        }

        all_funcs_used = unique(do.call(c, all_funcs_used))

        cache[[cache_name]] = all_funcs_used
    }

    cache[[cache_name]]
}

cache = new.env()

add_function_to_cache("data.frame", cache)

# How and why did this find my local f function? Strange.

# Wow, 469 different functions!
names(cache)

cache[["base::data.frame"]]
