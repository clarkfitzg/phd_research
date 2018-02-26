Fri Nov 18 14:47:40 PST 2016

## Traffic Data Analysis.

Described problem in traffic engineering class. The goal is to find and
characterize anomalous traffic events using occupancy data in PeMS. Then we
can link this with CHP incident data and use regression to understand the
impacts of different types of incidents on traffic. [More in
LaTeX](https://github.com/clarkfitzg/phd_research/blob/master/analysis/pems/finalproj/report.tex).
Class Professor thinks this has the potential to be submitted for a paper.

The simplest thing to do:

1. Compute occupancy under normal conditions, say for a Monday
2. For each Monday, compute the difference from normal conditions.
3. Threshold this difference to flag outliers by tuning some $\delta$.
4. Mark connected components as traffic events.
5. Compute summaries on traffic events: convex hulls, bounding boxes,
   Area, centroids.
6. Relate highway incident data to events and think about how to do
   regression.


## Code generation

Macros are handled by preprocessor using simple text substitution.
Specific compilers may have all sorts of statements before variable
definitions a la
```
extern int foo();
```
These are called __modifiers__.

Starting to use RCIndex on `opencv`. I will work on [issue on
enums](https://github.com/omegahat/RClangSimple/issues/1) which is
unrelated to opencv. 

A further issue on enums is handling the bitwise enums versus regular
enums. It would be nice if we could get into the body of the code and use
this to determine which is a bitwise enum.

I'm still a little shaky on the correspondence between an R S4 object and
an enum. But I think this will become more clear as I work on it.
