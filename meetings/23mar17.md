Thu Mar 23 16:58:15 PDT 2017

I explained the initial naive file based split using R approach as a
preprocessing step before a `tapply` / `group by` operation.  Originally
data is organized by one file per day, but I want to do an operation on
each station ID.  This will be followed by iteratively reweighted least
squares on each group, something not known for easy parallelization /
streaming.

We don't want to be reinventing Map Reduce. It's good to try this out on
various systems though.

Rather than appending files for each station ID-  to make it truly massively
parallel we can create the individual station ID files for each day and
process those.

We could think about the problem as translating code. Start with the R code
(which doesn't run since the data is too big) and translate it into
something which will run. Then combine / enhance this with compilation.

This might take the form of the creation of an `agent` function such that
we can do something like:
```
lapply(files, agent)
Reduce(...)
```


TODO: Look up
[ADMM](https://en.wikipedia.org/wiki/Augmented_Lagrangian_method)
