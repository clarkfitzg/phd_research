Wed Feb  7 08:47:18 PST 2018

I'm thinking about using task parallelism based on GNU `make`.

This differs from Landau's `drake` in R because it would be generated
automatically, with no intervention from the user. Same thing with Xie's
Rmarkdown chunks.

I can think of a few use cases for this:

- task parallelism
- disk based caching of expensive intermediate computations
- iteratively sourcing scripts, ie. make a small change in the beginning
  and propagate the results

We would lose interactivity.

This article
https://www.cmcrossroads.com/article/pitfalls-and-benefits-gnu-make-parallelization
talks about the importance of unique names. Ie. if in some code two
different blocks define a variable called `x` that needs to be be used
later then those better be two different objects on disk.

This disk based approach could also overcome some of the difficulties with
out of memory errors. For example, if `x` is a large vector, say 50% of available
memory, and we call a vectorized function `y = f(x)` then this may not
work. But we can make it work by chunking through `x` on disk. This also
allows parallelism. This is somewhat like the ddR approach.

We can even get some level of interactivity by keeping the first few
elements, ie the `head()` separate and computing on that quickly. Let the
user iteratively refine their code until it's correct on this part, and
then run it on the whole thing.

It can also be more efficient to run based on keeping the same processes
around, rather than spawning new ones. This could integrate with make.

I'm thinking of computations that take somewhere on the order of 10 seconds
to a few minutes. This should be long enough to justify the overhead.

## Design


