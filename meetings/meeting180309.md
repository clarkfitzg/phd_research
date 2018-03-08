Summary: Mapping R code on data frames into relational algebra will let us
use powerful query optimization technqiues and push calculations into
underlying data storage.

Thu Mar  8 08:58:56 PST 2018

Notes before meeting with Duncan tomorrow morning.  Duncan expressed the
concern that we have to be careful to distinguish between the work that
Nick and I do for our theses. Nick's already got "tools for R code
analysis", so I should be doing something higher level. Thus I need to
specialize, ie. restrict the type of programs I'm looking at. Ideally I
can build on what he's done.


## Relational Algebra

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
ways to express the same calculation. For example, we can write `head(x +
5)` or `head(x) + 5`. The latter is more efficient when `x` is large. We
need a principled approach to infer that these two expressions are
semantically equivalent. If we map these R expressions into a purely
semantic representation then we can use algebraic rules to optimize them.
We can potentially even use an existing query optimizer.
Conversely, if we don't use something robust like an algebra I fear that
we'll end up with a collection of ad hoc heuristics.


## Integrating data


The exciting problems for me are when the
data is enormous. The data often start stored in some underlying technology
such as Hive, Cassandra, etc. These systems are highly engineered and often
capable of performing some part of the computation on their own, ie. at
least column selection and basic filters.

It's foolish to try to reinvent these systems (Norm Matloff might
disagree). I think the novelty and value lies in __integration__, ie. how
can we take some big complex data storage and processing engine and combine
it efficiently with R?

On a side note these true big data problems and systems seem to exist
more in industry and less in academia, for many reasons.


## Relevant technology

My end goal has always been to take (code, data, platform) and come up with
an efficient execution strategy. If this is going to happen then I need a
cost model for run time and a data storage abstraction.

Many of these larger systems use the Java library [Apache
Calcite](https://calcite.apache.org/) internally. I could see using Calcite
(or something like it) for query optimization and interfaces to data
storage. Calcite has a rich set of query optimization rules, so we can
start with those and then add any additional ones we have that are R
specific. The adapters to specific data storage give us a nice abstraction
that additionally allows pushing computation to the data.

Here's the specific API for building relational algebra expressions:
https://calcite.apache.org/apidocs/org/apache/calcite/tools/RelBuilder.html.

A side effect is that we would get an R / SQL converter.
