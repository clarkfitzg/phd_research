# Mon Jul 23 11:26:16 PDT 2018
#
# A test of how well I know R.


# Artificial closures
foo = function(x) bar(x, 100)
environment(foo) = new.env()

bar = function(x, y) list(x, y)
environment(bar) = new.env()

debug(bar)

foo(1)

# Now inside debugger, so we can inspect the frames.

sys.call()
# bar(x, 100)
# The call that triggered the debugger.

sys.function()
# Same as calling print(bar)

sys.nframe()
# 2
# foo calls bar, so we're two levels deep.

identical(environment(), sys.frame(2))
# sys.frame(2) gets the context, the frame on the stack where evaluation is
# currently happening. 

sys.parent()
# 1
# The parent frame

ls(sys.frame(2))
# "x" "y"
# The possibly unevaluated parameters to bar.
# TODO: Any difference between formals?

identical(parent.env(sys.frame(2)), environment(bar))
identical(parent.env(sys.frame(1)), environment(foo))
# TRUE
# Lexical scoping rules in effect. This allows evaluation frames search for
# variables according to their environments.
