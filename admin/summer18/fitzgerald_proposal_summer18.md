## 2018 Summer Research Award Application

## UC Davis Statistics Department

__Applicant:__
Richard Clark Fitzgerald, PhD Candidate

__Dates:__
I will be in Davis for the entire summer, except for 3 days to travel
to the Joint Statistical Meetings (JSM) in Vancouver.

__Other Employment:__
I will not be employed with the University or any other organization.
I have not received any award or reimbursement to cover the travel to JSM.
However, I do have an active NSF Graduate Research Fellowship.

__Faculty:__
Professor Duncan Temple Lang can endorse these research activities.

__Plan:__

On August 2nd I will present an invited talk at JSM in the section on
statistical computing organized by George Ostrouchov and Norm Matloff. The
title for the talk is __Automatic Parallelization of R Code__ and the
abstract is as follows:

> Conventional systems for parallel programming require users to modify
> existing serial code to take full advantage of a platform's computational
> capabilities. In this presentation we consider methods to automatically
> infer the potential for parallelism based on R language idioms and code
> structure. A system can then automatically transform the serial version of
> the code into equivalent new versions that offer improved performance. The
> parallelism could come from simple replacement of functions, or from more
> elaborate code rewriting, or even from mapping R code into a totally
> different technology.

This summer I plan to do the following research activities related to this talk:

- Continue to refine a general computational model for parallel code
  transformations. The steps include inferring the dependencies between
  expressions, scheduling on multiple processors, and generating executable
  code.
- Redesign my existing software, the [autoparallel
  package](https://github.com/clarkfitzg/autoparallel), to match the
  more general computational model. I will use R's S4
  object oriented system to improve clarity and extensibility.
- Develop a task scheduling algorithm based on forking and joining. This
  should work better for typical workloads in R where the program spends
  the majority of time in relatively few statements.
- Continue to develop general purpose code analysis and metaprogramming
  tools, which can be found in the [CodeAnalysis
  package](https://github.com/duncantl/CodeAnalysis). By the end of the
summer Duncan Temple Lang, Nick Ulle, and I plan to write a paper on this
to submit to the Journal of Statistical Software.
