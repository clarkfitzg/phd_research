Thought: Given an unordered set of expressions, could we infer what the
ordered script must be? Certainly not true in all cases, but here's a
trivial example where we could:
```
c = sum(b)
a = 100
b = a + 5
```
Would this be useful at all? Maybe for detecting errors in the code. But
that's not very interesting, because one can just do that with the regular
interpreter.

Thought: Lines of code can run in as task parallel if and only if they can be
reordered. True? Then rather than actually writing a
parallel evaluator we can permute the lines of code, inject a few comments,
and use `future` for evaluation.

Expanding on this, we could also use `future` as a mechanism for load balancing if
we have some idea how expensive each expression is. Better to
evaluate the long ones first in that case. Is that true generally?

Next steps:
- X Write manual parallel evaluation of the script
- Put the graph into a data structure handling the parallel blocks.
- Write automated output.

What are all the useful things to do when rewriting code?

Going through the very helpful docs here: http://www.omegahat.net/CodeDepends/design.pdf

I no longer remember the details of what the traffic simulation script
does. It would be helpful to visualize it at different levels of detail.
