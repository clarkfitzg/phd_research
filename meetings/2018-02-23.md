Mon Feb 26 10:37:22 PST 2018

We need to come up with ways to reason about code.

List questions we care to ask about code. We have already done some of this
in
[CodeAnalysis](https://github.com/duncantl/CodeAnalysis/blob/master/Topics/topics.md).
Once we have the questions of interest we can prioritize them and see what
data structures are appropriate. There will be several different ones. We
can review (briefly) the CS literature to see which already exist. 

Talk to Nistara and Lauren Adams for interesting use cases on accelerating
code. Lauren's requires a sparse data structure.

We would like to know the dimensions of variables throughout a program.
Then we can see which ones are very large, which provides hints on where to
optimize, for example by putting into a sparse data structure. Can
Nick's rstatic do this sort of analysis?

Need to focus on understanding code, and do some actual symbolic
computations.

Clark is interested in focusing on computations around data frames because
of the possibilities to interact with underlying data bases.

Duncan is interested in a broader system that can be extended to work with
any code.
