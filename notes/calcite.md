Tue Mar  6 15:28:31 PST 2018

# Calcite

Gabe Becker pointed me to [Apache
Calcite](https://calcite.apache.org/docs/reference.html) after my blog post
wishing for a query specification.

I'm reading through the docs now and am not completely sure what it does.

It provides a SQL parser. Thus we could potentially use it to create
something that takes in SQL and runs R code- the opposite of what people
normally do.

It allows one to directly build a tree of relational operators, which is
somehow more elegant than going through SQL. That is, we could translate R
into relational operators represented here.

The extensible cost based optimizer seems like something that would be very
handy.

Can we use it to hook into something like Hive on a more direct level?

Does Calcite use true relational algebra or the multiset version as in SQL,
which allows duplicate rows? More likely the latter. I should find out
with an experiment. This will make me more familiar with the library, too.

Questions for Calcite mailing list:

- What kind of user defined functions can I represent in Calcite? Ie.
scalar -> scalar, vector -> vector, table -> table?

The docs for function say _The result may be a relation, and so might
any of the parameters._ Which suggests that we can represent table -> table
functions.

Insights listening to Julian Hyde's talks.
Intermediate data frames that aren't saved are pretty much like views.
Caching / precomputing results can save enormous amounts of time.

Calcite seems pretty flexible in optimizing queries across different
systems- key value stores and nested data. Which makes me think it may
generalize to R objects beyond just data frames.

We could apply this to a single R computation- the idea is iterative
development.


