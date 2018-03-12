# NSF GRFP Fellowship Report

## 17-18 Richard Clark Fitzgerald

> Please write a 2-3 paragraph SUMMARY of your fellowship activities and
> major accomplishments within the last year. This should be written for the
> public, and should address both the Intellectual Merit and the Broader
> Impact of your work.


This past year I've written about both basic and research topics in
parallel computing in 25 posts in my blog "Data Programming" which can be
found at http://clarkfitzg.github.io/.

Fall 2017 marked the opening of the UC Davis Veterans Success Center, a
dedicated space in the campus Memorial Union "providing services to the
student veterans, service members and dependents of the Armed Services".
Since the opening I've worked closely with the coordinator Earl Raehsler to
volunteer weekly tutoring student veterans in mathematics and statistics.

In Fall 2017 I took another turn as the organizer of the statistics student
seminar that a fellow student and I initiated in fall of 2016. We have
successful transitioned the responsibility of organizing the seminar, which
is now in its 5th quarter.

In January 2018 I volunteered as an instructor at a 2 day Software
Carpentry workshop. Later in March I will attend a 2 day Software
Carpentry instructor training.

Intellectual front

The general theme of my research is to take relatively simple code and
transform it so that it can run more efficiently on larger data sets or in
parallel. I was able to do this successfully for one of the original
motivating problems for 3 billion data points of traffic sensor data. 
By running the program on an Apache Hive cluster the program run time went
from an estimated several days to 12 minutes.
Processing the entire data set allows us to go beyond a simple
parametric fundamental diagram to a nonparametric model based on
dynamically binned means.

In January I worked on a 

My experiments with R and Apache Hive led to the development of code
generation software 

which can be found online at 

I solved the This paper demonstrated a technique for efficiently combining
existing data analysis technologies to analyze data that will not fit in
memory. 

Broader Impact

- TA for 2 classes


Intellectual Merit

- Pems data analysis, shared on dash.
- Industry consulting data analysis
- Metaprogramming and code analysis software
- Springer paper with Matloff and Yancey  Encyclopedia of Big Data Technologies


I want to highlight two results:

__R in Hive__ `write_udaf_scripts` provides a massive speedup
with much less code complexity for two particular classes of problems with
large data:

- Applying a vectorized R function (one output for each row)
- Reduction based on grouping by one column (one output for each group)

This uses standard interfaces to allow R to process streaming data.  It
mainly integrates existing technology in a useful way that's compatible
with R's computational model, so it isn't really "new". This doesn't
analyze code, but it does generate code. The PEMS analysis demonstrates the
practical value of this.


__Column Use Inference__ `read_faster` analyzes code to
find the set of columns that are used and transforms the code to a version
that only reads and operates on this set of columns.


