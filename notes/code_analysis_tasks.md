Wed Feb 28 09:56:47 PST 2018

Meeting with Nick

# Code analysis 

We can do a few different things with code:

- __static analysis__ inspect and describe it
- __dynamic analysis__ run some portion of the code and see what happens
- __transpile__ modify the code to make it more efficient while staying in
  the same language.
- __compile__ compile into machine code.

I'm interested in analyzing data analysis scripts that are roughly
somewhere between 10 and 1000 lines of code.

Most of the analysis tasks I have in mind have are motivated by the
potential to do some kind of modification. This is a different use case
than seeking purely to understand the code.

## What should a general R code analysis framework look like?

I like the notion of "optimization passes", meaning that we walk through the
code and make one type of change. For example, an early optimization pass
might be removing all unnecessary code.

It should be extensible in the sense that I would like to add information
after profiling / running the code.


## What would I like a general static code analysis system to identify?

__Vectorized and scalar valued functions__

Then we can better infer the sizes of the data that pass through.

__Group semantic units__

Gather together code that must always run together. For example, to
produce a plot we need all the plotting calls between `pdf("myplot.pdf")`
and `dev.off()`.

__Statements or semantic units in data analysis code that actually produce
output.__

If these statements execute, ie. build a plot or save some result to a
file, then the script has run successfully. 

__Unnecessary statements__

Then we can remove them.

__Earliest place to run subset operations__

If we only need a subset of rows and columns to do the required task then
we can filter the data early, even at the source. This saves memory and
time for intermediate computations.

__Calls / statements likely to be slow__

Think about machine learning for code- code and data sizes should be able
to predict the timings / profiling information.

__How much memory any statement will consume__

Memory use and copying is notoriously hard to predict in R.

__When will a variable be copied__

__The random number generator is called__

This requires special handling for parallel applications.

__Variable lifetimes__

For example, the remainder of the code doesn't use `x` so we can safely `rm(x)`.

__When is it necessary to keep the names__

I've ran into this as a particular problem- a default was to compute the
names so the code took an order of magnitude longer than it should have.
If the remainder of the code doesn't use the names then we don't ever need
to do any operations on the names.

__Statements that can be made more efficient by data reorganization__

For example, `group by` operations can be done streaming if the data
has been grouped at the source.

__How often special statements are used__

Language aspects such as control flow, superassignment, and nonstandard
evaluation in general make code analysis more difficult. If we can know
that code does or doesn't use it then we can use specialized versions of
the code analysis.
