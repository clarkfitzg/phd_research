Wed May 10 08:05:30 PDT 2017

## My notes



## Duncan's notes

These are thoughts for your QE and research generally.

You may want to have a response for "why not use Julia?" Python? Go? ...

While we are currently looking at parallelism, we are more generally trying to 
automatically make code faster. Parallelism is one way. Compiling another.
Mapping code to alternative computational implementations another.
Basically it is code analysis and reorganiztion to equivalent results.  
See below for remarks on compilation in your research.


Code Analysis:
For example, if you know the schema or simply can read the names of the columns from the first 
line of the CSV (or by reading the skip =  arguments), you can analyze the remainder of the code
to see if some columns are not used. If so, you can add colClasses = list(..., NULL.., ) for these.

CodeDepends and Parallelism:
I think the stuff you were doing with CodeDepends to identify potential parallelism
of expressions may warrant mention in your QE. 
It is nice and understandable, has immediate impact, and illustrates some of the ideas
in terms of rescheduling the code. It doesn't have to necessarily rewrite the code, but 
just run it in a different order and in different R processes.
And it grows into a richer, more complex problem.

An example: In Pablo's code (https://github.com/dsidavis/Pablo), 
the first two expressions in setup.R are calls to read.csv().
These could be done in parallel.  If the code for read.csv() was thread-safe, it would be easy.
However, we can fork and read the smaller of the two CSVs into the worker
and then send it back.  And we chose the smaller CSV to minimize the movement
of the data. 

Note that the second data frame (Farms) is not used until line 90. See setup.R
So this really does look like a case of
 A,  B, C ..... Z
could be reordered as
  A\ C ...Z/
    \     /
     B  
where B is being evaluated while C .. Z are also.

But we can do better. Lines 93 - 127 only deal with Farms, so we would add
  A\ C ...  ...Z/
    \          /
     B B2 ...B3  
and have all of those computations from 93-127 be done in the worker.

Of course, these may not be in adjacent lines of code in the file. We would detect this and 
order the expressions for the host and worker.

And generally we may be able to go further.  We don't have to return the data from the worker
to the original R process. 
 1) We might return only a subset of it. 
 2) Or we may break up other later expressions and send part of them to the still alive worker 
    and have it do one or more computations and send back intermediate results.
The key is to speed things up, which involves running in parallel and minimizing data transfer.
(Need to make a concrete example for this.)

This example shows 
 a) code analysis, 
 b) rewriting to equivalent results, 
 c) parallelism, and 
 d) dispatching code to different workers that remain alive to receive tasks.


I think it would be good to work out a concrete example - perhap's Pablo's or your 
transportation code - that gives a benefit and shows how the serial code can be reorganized.


Platform:
I think it would be good to try to find one example for *each* of the platformws we are considering
where that approach works best. The platforms are 
  multicore shared memory
  networked machines and distributed memory 
  GPUs
  Spark/MapReduce


Compilation:
Also, a slide or few on potential for compilation.
Again, this is about making code faster, not only by parallelism.
Nick's work probably will not go as far as smart heuristics for compiling
(it already involves type inference, mapping to machine code, control flow graphs,
basic compilation, and some basic compiling of R, interfacing to existing C code
in R, native and R objects and garbage collection, ...).
So your research could pick up where he leaves off, as well as on parallelism,
should we want to.

But compilation opens up the whole world of threads. By compiling R code to machine
code, we avoid the lack of thread-safety of the R interpreter (by avoiding the interpreter).
So then we can exploit threads in our compiled code.

....
## 2nd email
....


Can you ask fellow students for example code from their research that they want to speedup?
or just generally to see if we can speed it up?
Or just code they have that they have used in the past?
And Nick might ask the STA260 cohort about their code?
This might include C code that they used to make things faster, but which they would like to
implement in R.


A slide or few on how we can exploit information about "data description" or 
metadata would be good as we discussed today.
Imagine what we could do if we had different types of information about 
the dataset(s).  Go from practical to ideal information and outline what that
information would enable us to do to make the computations more efficient.
These might be
 number of rows
 whether it is sorted/grouped by one or more variables
   e.g. sorted by time/date
               by observational unit, but with multiple variable number of records for each
 sufficient statistics for the rows and between rows
   sufficiency assumes, e.g., an exponential model
 types
 in files, databases, HDFS, 
 what are the indexed variables/columns in a database
 ... 
 the issues you wrote down in your notebook - I'd like to see those, please.

These influence how to process the data
  move it between machines
  visit it with code on machines on which the different data resides
 

These 2 sets of comments focus on
 code analysis, rewriting to different computational implementations
 exploiting the best of the different parallel platforms
 knowledge of the data that we can exploit to improve computation

 It is is the fusion of these three pieces  of information that allows us to 
  take simple-minded sequential code and 
  repurpose it for different situations 
  w/o the user's intellectual actions to rewrite it
  to enable more efficient equivalent computation.


As we discussed, we may need "hints" or intelligence to identify
about data descriptions. How can we 
 specify these
 utilize these
   in what ways
   how for each platform.
