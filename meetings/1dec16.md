Thu Dec  1 12:13:25 PST 2016

Discussed more about possible research topics. 

I proposed implementing solution to transportation problem using parallel
R, Python's dask, and Spark. Then compare results and see which work well.
Duncan cautions that I need to be careful that it doesn't turn into an
extended Master's thesis.

Suggestion: setup weekly meeting with Matt to learn and implement C/C++.

Duncan's recommendation for how to spend time: 60% with hands on working,
ie. learning C and further implemention on RCIndex / RCodeGen. 40% with
literature and framing problems. Most of this quarter I've spent thinking
about different problems and areas to pursue. Our meetings have been high
level- might be more productive if I come to them with something that I'm
stuck on.

Include in final write up some thoughts of what I've learned about the
research process- ie. why am I reading each paper?

Statistical computing is tricky area to study in academia because the line
between implementation and new ideas can be fuzzy.

Ask other students how they get their research problems.

## The holy grail

A user writes simple code that's correct on a small dataset. They put that
in the oven and out comes a piece of compiled that can run on Petabytes of
data.

## Two broad areas

### RCIndex

Duncan has already done a fair amount here. It's not clear how much it's
worth to go in and implement all the technical details required to manage
memory or other related extensions. Nevertheless it would be good to have the experience and knowledge
with C/C++, as well as working bindings for opencv.

This can also lead to more software engineering tools like code viz.

### Parallel

Automatic detection and inference of parallel code. Ie, can we detect what
the proper chunk size is?

It might be possible to implement a system in R on top of dask itself.

Compiling code for different systems, ie. GPU.

My reservation with some of this is that Python already has mature systems in dask
and numba. Many engineering man years have been put into making these work well.

Could also work on the NIMBLE stuff, maybe map that into GPU? Bayesian
statistics becomes more interesting as computers become more powerful.
