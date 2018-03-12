# NSF GRFP Fellowship Report

## 17-18 Richard Clark Fitzgerald

> Please write a 2-3 paragraph SUMMARY of your fellowship activities and
> major accomplishments within the last year. This should be written for the
> public, and should address both the Intellectual Merit and the Broader
> Impact of your work.

During the last year I've volunteered as a tutor, seminar organizer, and
programming instructor. 2017 marked the opening of the new UC Davis
Veterans Success Center. I continue to work closely with the coordinator, Earl
Raehsler, as a weekly tutor in mathematics and statistics for student
veterans. Last fall I took another turn as the organizer of the
statistics student seminar that a fellow student and I initiated in 2016.
We successfully transitioned the organizer role between students, and the
seminar is now in its 5th quarter.  In January 2018 I co-instructed a 2 day
Software Carpentry workshop catered towards graduate students in the life
sciences. Later in March I will attend a 2 day Software Carpentry
instructor training so that I can improve my skills in technical
communication.

The general theme of my research is to take computer code that analyzes
data, understand the code, and find ways to automatically make it more
efficient. In June 2017 I passed my PhD oral qualifying exam by presenting
a talk titled "Parallel Computing Through Code Analysis". I described a
motivating application to traffic engineering of a qualitatively new kind
of analysis that requires processing 3 billion data points. In the fall I
completed this analysis, demonstrating how to generate code to efficiently combine several
specific technologies. I'm currently focusing how to generalize the code
analysis techniques. Along the way I've learned much
about parallel computing and was able to contribute to an article "The R
Language: A Powerful Tool for Taming Big Data" which will be published in
the "Encyclopedia of Big Data Technologies" this year.

I've made my results available to a broader audience through software and a
blog. This past year I've written about both basic and research topics in
data intensive computing in 25 posts in my blog "Data Programming" which can be
found at http://clarkfitzg.github.io/. The techniques for parallelism
are available in the `autoparallel` package at
https://github.com/clarkfitzg/autoparallel.

For the majority of my research time I've focused on developing and
describing methods to 

I was able to do this successfully for one of the original
motivating problems for 3 billion data points of traffic sensor data. 


By running the program on an Apache Hive cluster the program execution time went
from an estimated several days to 12 minutes. In this case processing the entire data
set was key 

qualitatively new types of analysis 

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


