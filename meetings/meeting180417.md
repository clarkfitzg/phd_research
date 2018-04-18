Tue Apr 17 17:21:48 PDT 2018

Duncan and I were talking about an abstract for my JSM talk.

Goals of talk:

- Show feasible
- Show where it makes a difference
- Incremental growth of ideas, why interesting?

I should have a package out by the time of my talk. This package should be
fairly complete in terms of representing the parallel structure in the
code. After I have this I can think about an actual scheduler, whether it's
static or dynamic. 

I currently have code that creates a task graph for the variable uses. This
builds directly on CodeDepends.
Whatever data structure(s) I use for parallelism, the goal is to represent
as many different types of parallel code as I can. Next I need to add:

- lapply / vectorized embarrassingly parallel nodes
- Nested expressions, down to literals and symbols
- for loops

The scheduling is a different problem altogether- the goal of this parallel
data structure is to be orthogonal to the scheduler, so that we can plug in
different ones.
