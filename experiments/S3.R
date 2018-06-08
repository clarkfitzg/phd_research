foo = function(a, b = 7, ...)
{
    UseMethod("foo")
}


foo.default = function(a, b, ...)
{
    browser()
    list(a, b)	
}
 
out = foo(10)
