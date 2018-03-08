Summary: Mapping R code into relational algebra will let us use powerful
query optimization technqiues and push calculations into underlying data
storage.

Thu Mar  8 08:58:56 PST 2018

Notes before meeting with Duncan tomorrow morning.  Duncan expressed the
concern that we have to be careful to distinguish between the work that
Nick and I do for our theses. Nick's already got "tools for R code
analysis", so I should be doing something higher level. Thus I need to
specialize, ie. restrict the type of programs I'm looking at.
Ideally I can build
on what he's done.

I've been thinking about how to represent R code in a way that facilitates
analysis and transformations. 

Some points that we've agreed on before:

- R tends to be more high level and declaractive, rather than procedural.
- A useful code analysis task is to standardize R code, ie. transform it into a
  canonical form.
- Programmatically rewriting R code for performance is useful if we can be
  sure that the results will be the same.

Duncan has shown that compilation is very helpful for accelerating
procedural R code. I'm interested in working with the more declarative
code, ie. manipulating data frames.

One difficulty with standardizing R code is that there are often several
ways to express the same calculation. For example, we can write `head(x + 5)`
or `head(x) + 5`. The latter is more efficient when `x` is large. We need a
principled approach to infer that these two expressions are semantically
equivalent. If we map these R expressions into a semantic representation
then we can use algebraic rules to optimize them. Conversely, if we don't
use something robust like an algebra I fear that we'll end up with a
collection of ad hoc heuristics.


What would be even better is to map the code to semantics.

My end goal has always been to take (code, data, platform) and come up with
an efficient execution strategy. The exciting problems for me are when the
data is enormous. Industry seems to ha

For me the most exciting problems are 

. It's better to integrate and build on existing software infrastructure when possible.
