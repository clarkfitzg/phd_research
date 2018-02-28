Mon Feb 26 13:25:22 PST 2018

Following meeting with Duncan on Friday I'm writing down questions to
answer with code analysis.

Duncan's use case: people come him with code to make faster. They often
give him the whole data set which may take days to run. It would be neat to
look at the code and then artificially create a data set that is similar to
the large one. This must be similar to generated tests that aim to explore
every branch.

## Outcomes

What are my high level goals?

__Speed__

Take code that runs in 20 minutes and make it run in 10 minutes. There are
many ways to do this: detecting programming mistakes, compilation,
parallelism, dropping in more efficient implementations, etc.

__Memory__

Take code that requires 5 GB, and run it in a way that requires only 2 GB,
or even just 10 MB. This may be possible with streaming computations.

__Data Abstraction__

Take code that runs on a local data frame and evaluate it efficiently on
any tabular data source. The data could be a table in a database, a bunch
of files in a local directory, or a file on Amazon's S3.


There are three distinct things we can do with code:

- __static analysis__ inspect and describe it
- __dynamic analysis__ run some portion of the code and see what happens
- __modify the code__ change the code to make it more efficient in some way

Most of the analysis tasks I have in mind have are motivated by the
potential to do some kind of modification. This is a different use case
than seeking purely to understand the code.


## What would I like a general code analysis system to do?

__Tell when a function is vectorized or scalar valued.__

Then we can better infer the sizes of the data that pass through.

__Identify and group the statements in data analysis code that actually
produce output.__

If these statements execute, ie. build a plot or save some result to a
file, then the script has run successfully. 

__Identify unnecessary statements.__

Then we can remove them.

__Identify the earliest place to run subset operations.__

If we only need a subset of rows and columns to do the required task then
we can filter the data early, even at the source. This saves memory and
time for intermediate computations.


## What should a general R code analysis framework look like?

I like the notion of "optimization passes", meaning that we walk through the
code and make one type of change. For example, an early optimization pass
might be removing all unnecessary code.


## High level Questions / Tasks

__Cloud Computing__

If we pay for computation and storage then we can do things based on cost.
We have access to a potentially limitless amount of computing power.
Things we might like to do when evaluating a particular piece of code on a
particular data set:

- Minimize cost
- Minimize time
- Minimize cost such that the computation takes no more than `h` hours
- Minimize time such that the computation costs no more than `d` dollars




## More Technical

What else do I want from the R code analysis? 

What kind of data frame will a function call generate? Column 
