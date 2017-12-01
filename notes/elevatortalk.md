Thu Nov 30 08:03:50 PST 2017

How do I describe my research in 30 seconds? What are the big questions to
answer?

Can a system take an arbitrary piece of data analysis code and adapt it to
the data and platform? The idea is to take a simple, possibly naive
implementation of a data analysis program in the R language and transform
it to something that runs reasonably efficiently.


## General techniques

Given some existing implementation in code, how can we accelerate it?
To make code fast, I would first profile it, and then take these steps in
this order:

1. Ensure the code doesn't do anything crazy, such as computing the same
   value many times.
1. Use the right algorithm / data structure. For example, a hash table is
   appropriate for key value lookups if there is enough data. 
2. Run the code in parallel.
3. Compile / rewrite using a more efficient language.

The first two are in some sense fundamental errors. Some we can detect,
some we can't.

In R, hopefully we're delegating expensive computational tasks to a well
written underlying implementation. This is a common case. Then we don't get
any speed from the last one.

This leaves only running the code in parallel.


## Parallel techniques

H
