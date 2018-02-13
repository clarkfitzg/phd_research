
code = quote(x <- 5)
code
eval(code)
x
x = 20
code2 = call("local", call("{", code))
code2
eval(code2)
x
