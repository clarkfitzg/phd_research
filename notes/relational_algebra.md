Wed Mar  7 09:37:11 PST 2018

Does Calcite use true relational algebra or the multiset version as in SQL,
which allows duplicate rows? More likely the latter. I should find out
with an experiment. This will make me more familiar with the library, too.


# Relational Algebra

Thinking about translating R into relational algebra.
This abstracts R code into a semantic representation with some well
developed theory behind it.

In relational algebras the domain is tables. The differences between an R
data frame and a table in relational algebra are:

- R data frame has ordered columns and rows (unlike SQL)
- R data frame allows duplicate rows (like SQL)

To do symbolic manipulation of code we really need some kind of algebra.
Otherwise everything is ad hoc rules.

Correspondence between R data frame functions and relational algebra

relation    |   base R      |   data.table  |   dplyr
------------|---------------|---------------|--------
binary union       | `rbind`       |   

