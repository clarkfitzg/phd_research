Thu Oct 20 10:15:42 PDT 2016

Discussed more research directions. We keep coming back to code analysis
and running R in parallel, so this seems like the direction to proceed in.

It's time to start digging deeper into these questions now.

R has so much traction in statistics and data analysis that it's unlikely to be replaced. So
then we focus on ways to improve it, in particular allowing it to scale up
to larger data sets.

It's currently unclear when one software tool is the best approach for a
data analysis problem. Ie. do we use R, Python, database, Spark, etc.
Having better relative comparisons would be nice.

A PhD should be about introducing new ideas, and code is just a way of
expressing them.

### For next time

Dig more into the problem and literature of detecting parallelism.

Conceptual understanding of Henrik Bengston's [futures
package](https://github.com/HenrikBengtsson/future), and how we
it relates. Does it do code analysis?

From the Github page:

> For instance, a future can be resolved using a "lazy" strategy, which means
> it is resolved only when the value is requested. Another approach is an
> "eager" strategy, which means that it starts to resolve the future as soon
> as it is created. Yet other strategies may be to resolve futures
> asynchronously, for instance, by evaluating expressions concurrently on a
> compute cluster.

Asynchronous model blocks when code attempts to use a future that is still
being evaluated. Some code analysis happens in [identifying global
variables](https://github.com/HenrikBengtsson/future#globals)
