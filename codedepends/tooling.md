
> Let us change our traditional attitude to the construction of programs.
> Instead of imagining that our main task is to instruct a computer what to
> do, let us concentrate rather on explaining to human beings what we want a
> computer to do.

- Don Knuth

## Main idea:

One can inspect the code itself at a high level from within R, programming
on the language and potentially making changes to how the evaluation
happens.

## Changes to Make

Dependency graphs should include functions that are created and called
later.

`makeTaskGraph()` should also work for functions, not just scripts.

Handle `source()`

## Lofty Goals

Help make code fast / adapt to larger data:

Parallelize by injecting code where it's worth it. So what is the minimal
overhead for a system fork? This helps you know if it's going to be worth
it. Also when to fork... after loading all needed data.

Code visualization tools. Ie. mouseover a node to see the corresponding
code.

Profiling Visualization of run time in each statement?
