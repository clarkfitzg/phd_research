Summary: Mapping R code on data frames into relational algebra will let us
use powerful query optimization technqiues and push calculations into
underlying data storage.

Thu Mar  8 08:58:56 PST 2018

Notes before meeting with Duncan tomorrow morning.  Duncan expressed the
concern that we have to be careful to distinguish between the work that
Nick and I do for our theses. Nick's already got "tools for R code
analysis", so I should be doing something higher level. Thus I need to
specialize, ie. look at some particular types of programs. Ideally I
can build on what he's done.


### Need for Algebra

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
semantic representation then we can use algebraic rules to make valid
transformations.  We can potentially even use an existing query optimizer.
Conversely, if we don't use something robust like an algebra I fear that
we'll end up with a collection of ad hoc heuristics.


### Integrating data

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


### Relevant technology

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

Downsides:

- Calcite is Java, and I don't know Java.
- It may be easier to just reimplement a poor version of Calcite.

Here's the specific API for building relational algebra expressions:
https://calcite.apache.org/apidocs/org/apache/calcite/tools/RelBuilder.html.

A side effect is that we would get a two way translator between R and SQL.


------------------------------------------------------------

Notes from talking with Duncan.

My notes again are too high level. I need to be communicating more detail
along with examples, motivation, and a coherent narrative.
At the same time I need to stay at a higher level than the implementation.
I also need to demonstrate that I have thought through and understand the
concepts. Basically I need to be doing a whole lot more writing. Then I can
send it to Duncan a couple days before I'm ready for feedback.

Focusing on tables and relational algebra is acceptable, as long as it's
somewhat general.  It can't just be "we can handle this one type of
expression and only on Hive".  Duncan is less excited about this than I am.
We need to say why this is relevant, talk to people. Musing, who might I
talk to? Noam Ross, Simon Urbanek, Mike Kane, contacts at Stitchfix and
Google.

Don't let the tail wag the dog with the software. For good design we think
about what it should do, what you want. Say "these are the concepts we need
to represent", so that the design comes down from the top level. The wrong
way is to look at a related package and say "this is what it does so we
should fit ourselves to it."

What am I going to do in the next couple weeks? Explicitly describe what I
hope to get from mapping R code to relational algebra and __how__ I plan to
do it. Build a narrative. Write a bunch. This will make it easier to write
my thesis- most stuff will probably get cut, but that's better than trying
to write everything at the end.
