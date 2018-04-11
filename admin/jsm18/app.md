Please give a brief description of why it is important that you attend this
meeting:

UC Davis Professor Norm Matloff invited me to present my research in a
session titled "Statistical Computing on Parallel Architectures".  JSM (the
Joint Statistical Meetings) is the largest gathering of statisticians and
data scientists held in North America. This will be my first time
attending.  I plan to use this opportunity to connect and share ideas with
the broader community of researchers focused on my specialized area of
parallel statistical computing.


RESEARCH STATEMENT
Please describe in 300 words or less the research you plan to present (do
not assume that the reviewer will be an expert in your field):


My research focuses on code analysis to increase the performance of the R
language for statistical computing. I increase the performance by inferring
parallel structure and automating code generation so that the computer(s)
can execute multiple instructions simultaneously. This allows researchers
to scale up analyses to ask new questions on larger data sets.  The current
state of the art is for _users_ to modify their code when they need to run
code in parallel. I'm working on a _system_ capable of doing this
modification for them automatically. This requires careful analysis of the
language as an object using metaprogramming techniques. With such a system
a user can take potentially sophisticated custom data analysis code written
in R and generate correct and efficient parallel code specialized for
different platforms. 

I will demonstrate an application of these techniques to a motivating
example in automobile traffic modeling. These techniques allow us to write
relatively simple code to express a qualitatively new kind of analysis that
we can then run on billions of data points in a distributed database.
