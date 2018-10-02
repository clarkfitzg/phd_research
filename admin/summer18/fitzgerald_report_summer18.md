## 2018 Summer Research Award Report

## UC Davis Statistics Department

Richard Clark Fitzgerald, PhD Candidate

On August 2nd I presented an invited talk at JSM in the section on
statistical computing organized by George Ostrouchov and Norm Matloff. The
title for the talk was __Automated Parallelization of R Code__. Here's the abstract:

> Conventional systems for parallel programming require users to modify
> existing serial code to take full advantage of a platform's computational
> capabilities. In this presentation we consider methods to automatically
> infer the potential for parallelism based on R language idioms and code
> structure. A system can then automatically transform the serial version of
> the code into equivalent new versions that offer improved performance. The
> parallelism could come from simple replacement of functions, or from more
> elaborate code rewriting, or even from mapping R code into a totally
> different technology.

The talk went smoothly, and the audience seemed to appreciate it.

This summer I did the following research activities:

- Refined a general computational model for parallel code
  transformations. The steps include inferring the dependencies between
  expressions, scheduling on multiple processors, and generating executable
  code.
- Enhanced my original software design to match the
  more general computational model. I used R's S4
  object oriented system to improve clarity and extensibility.
- Published the software to CRAN in the [makeParallel
  package](https://cran.r-project.org/package=makeParallel).
  I've continued to debug and add features to the package.
- Developed a divide and conquer task scheduling algorithm based on executing
  the two longest running statements in parallel. This should
  work well in R because typical R programs spend most of their time in
  relatively few statements, and system level software
  (`parallel::mcparallel`) directly supports this type of code.
- Written examples and explanations of the techniques and the research concepts.
  I now have about 100 pages of rough material that I will continue to revise into my dissertation.
