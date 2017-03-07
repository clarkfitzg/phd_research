# Mon Mar  6 12:00:20 PST 2017
# All of this probably only works with simple global assignment, not fancier
# things like <<-


library(parallel)


#" Return Assignments Made In Expression As List
assign_catcher = function(expr)
{
    output = new.env()
    eval(expr, envir = output)
    as.list(output)
}


#" Update Environment Variables With Named List
update_env = function(updates, env = parent.frame()){
    for(varname in names(updates))
    {
        assign(varname, updates[[varname]], envir = env)
    }
}


#" Run Event Loop Collecting Variables Into Global Environment
eventloop = function(unevaluated, SLEEP = 0.01, MAX_TIME = 10)
{

    t0 = Sys.time()

    # Base case:
    job = mcparallel(assign_catcher(unevaluated[[1]]))
    active = job$pid
    unevaluated = unevaluated[-1]

    while(TRUE){
        # The ordering of code in this block is important.
        if(length(unevaluated) == 0 && length(active) == 0){
            message("All done.")
            break
        }

        if(Sys.time() - t0 > MAX_TIME){
            stop("Timed out.")
        }

        Sys.sleep(SLEEP)

        collected = mccollect(wait = FALSE)

        if(is.null(collected)){
            next
        }

        # Update global variables in master
        lapply(collected, update_env, env = .GlobalEnv)

        # update active list
        completed = as.integer(names(collected))
        active = setdiff(active, completed)

        # Set up next evaluation
        if(length(unevaluated) > 0){
            job = mcparallel(assign_catcher(unevaluated[[1]]))
            active = c(active, job$pid)
            unevaluated = unevaluated[-1]
        }
    }
}
