## Concepts

### Writing

__Technical Reports__
What are the bottlenecks in a program?
What are the options to fix it?

__Paper Summaries__
Read original papers on Hadoop, Hive, etc.

__Learning Narrative__
Idea: separate the report on the data vs. what you learned / used to solve it, problems you ran up against.

### Software Engineering

__Errors__
How to read a stack trace?

__Debugging__
Debuggers are better than print statements

__Profiling__
Never assume you know what's going on.
Measure your program.
Profiling is different than a microbenchmark
"Premature optimization is the root of all evil."

__Logging__
Save the results to look at them later.
Even just a stack trace is better than nothing.

__Software Reuse__
Use standard, existing tools where possible.
Good example- R's Matrix package.
Use the _minimium_ tool that gets the job done- if you can do it on a server in 2 minutes and you don't anticipate this growing, then why bother with Hadoop?

__Unit Testing__
Test driven development, write a test and documentation first.

__Automation__
`GNU make` works well, and we can use this to test everyone's code all at once.


### Data

__Physical Data Types__
What is an array of doubles?
Leads nicely into C programming.

__Vectorization__
Intermediate copies, R's memory model.

__Data Representation__
Sparse data structures can save on both space and runtime.

__Low Rank Matrix Decompositions__
Approximately represent large data more efficiently, see notes from Udell's talk.

__stdin stdout__
UNIX pipes- standard interfaces for data transfer between processes.
Can show pipeline parallelism here.
Fun example might be to pipe from text file to Python to Julia to R to a database.
Some of these low level tools can be quite efficient: `sort, split, cut`

__Chunking__
Data too big?
Cut it up into pieces that you can work with.
This can be parallel too.

__IID__
`SELECT * FROM data LIMIT 5;` is _not_ IID.

__Map side join__
One big table larger than memory, one small table that fits in memory, do something that requires joining the two.


### Project / HW ideas

__Animal movements__
Given GPS tracking data of where the monkeys have moved, describe how they behave.

__Julia on GPU__
Can compile and run Julia code directly?
