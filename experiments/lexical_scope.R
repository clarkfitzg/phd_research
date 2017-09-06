# Tue Aug 22 16:02:21 PDT 2017
#
# Attempting to understand the difference between lexical and dynamic scope
# based on the Wikipedia definition:
# "
# with dynamic scope the calling function is searched, then the function
# which called that calling function, and so on, progressing up the call
# stack
# "

x = "global"

f = function() print(x)

g = function(){
    x = "inside g"
    f()
}

# If this prints "inside g" it's dynamic.
# If "global" then lexical.
g()


############################################################

f = function() y

g = function(){
    y = 20
    f()
}

# calling g() fails to find y:
g()

# Is there a way to make f find y?

ffactory = function(){
    function() y
}

g = function(){
    f = ffactory()
    y = 20
    f()
}

g()

# This doesn't find y, since the parent environments for f come from
# ffactory, then the global environment.
# How about modifying the environment?

f = function() y

g = function(){
    y = 20
    f()
}


# Wed Sep  6 11:31:29 PDT 2017
# Actually what I really want is to construct a call and evaluate it
# somewhere else.

f = function(y) y + 1

call = as.call(list(as.name('f'), as.name('y')))

trace_func = function() eval(call)

g = function(){
    y = 20
    trace_func()
}

# Doesn't find y because of lexical scoping
g()


# Now something trickier...

#trace_func2 = function() browser()
trace_func2 = function() eval(call, parent.frame(1L))

g2 = function(){
    y = 20
    trace_func2()
}

g2()
