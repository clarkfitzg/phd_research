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
