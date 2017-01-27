Thought: Lines of code can run in as task parallel iff they can be
reordered. True? Then rather than actually writing a
parallel evaluator we can permute the lines of code, inject a few comments,
and use `future` for evaluation.

Next steps:
- X Write manual parallel evaluation of the script
- Put the graph into a data structure handling the parallel blocks.
- Write automated output.

What are all the useful things to do when rewriting code?

Going through the very helpful docs here: http://www.omegahat.net/CodeDepends/design.pdf

I no longer remember the details of what the traffic simulation script
does. It would be helpful to visualize it at different levels of detail.
