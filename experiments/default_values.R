# Thu Oct  4 13:06:11 PDT 2018
#
# Problem: I'm not seeing dependency with function defaults.

library(CodeDepends)

code = parse(text = "
a = 100
f = function(a = a) a + 1
f()
")

x = lapply(code, getInputs)

eval(code[1:2])

# Only +
codetools::findGlobals(f)

# The actual globals depend on the call.
# f() then a is global
# f(a) then a is not global
