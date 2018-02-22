Thu Feb 22 09:06:00 PST 2018

Had a rough night with the 2 year old last night, so these thoughts might be a
little scattered.

High level question:
What features make R code more or less easy to analyze?


## SQL Example

I would like to treat the code as orthogonal to the data. This is what SQL
does. SQL is declarative, it describes what to do. To actually execute the
query a database must parse the SQL and compile it into physical operators that run
in that database. SQL generally separates the data loading steps from the query.

Some attractive features of SQL:

- Queries don't utilize physical structure of data (although indexes do,
  but this is really just for performance tuning).
- Simple set of data structures, ie. the only objects are tables consisting
  of columns with basic types.
- Tables are closed under queries, every query produces another table.
- Relational algebra provides a sound theoretical basis.

This generalizes beyond tables, for example we can compute on mathematical
algebraic structures using symbolic algebra.

We can evaluate a domain specific language (DSL) like SQL using several criteria:

- Clarity and elegance of the conceptual model of the language
- How easily the DSL expresses the common tasks it was designed for
- Flexibility to express more complex tasks using the DSL
- Ability for a system to map (or compile) the DSL into efficient physical
  instructions


## R data frame

Some of the dplyr stuff maps R to SQL

If I restrict the scope of code analysis to data frames then there are 3 DSL's:

- data.table
- dplyr
- [rquery](https://winvector.github.io/rquery/) (new package, but designed
  with this sort of optimization in mind)

I call them DSL's because they're all similar to SQL type queries on
tables. What I'm thinking about doing then is a sort of global script
optimization on these languages, which is sort of like PL/SQL.

