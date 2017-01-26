Wed Jan 25 17:03:33 PST 2017

Asked if software or academic writing is a preferred output / product as I
do the PhD. Answer- ideally both :)

Be careful with managing time if getting pulled into other projects.  Make
sure to estimate how long something will take up front before agreeing to
it. Then double that, at least.  Software development can take up a lot of
time. If it's adopted and successful it's even worse, because then people
ask you questions.

Duncan mentioned the GPU gems book- looked it up online, seems more
oriented towards graphics, but they have a copy in the engineering library.
It's 10 years old now, maybe a little dated.

Considering different technologies- Julia is on the one hand 
compelling and ideal, and on the other hand pretty advanced with regards to
the computer science. Which may make it difficult to contribute to it- they
have Julia compiling to [GPU code
already](https://arxiv.org/pdf/1604.03410.pdf). In Python
[Copperhead](https://devblogs.nvidia.com/parallelforall/copperhead-data-parallel-python/)
has been doing something like this since 2013. R potentially has lower
hanging fruit. And it's not going away.

In general Duncan prefers experimentation and quickly putting new concepts
together over making bulletproof software. Makes sense for research

## Parallelization

The main problem is how to split and move data. How to bring computations
to the data efficiently.

How do we compile R into a kernel? Some things have been done compiling to
PTX code and running on GPU's.

One idea: Do __more GPU code__. Take a serial program in statistics and map it
onto the GPU. For example decision tree prediction. Might need several
thousand points to make this worthwhile.

Look up Mark Suchard from UCLA- did early work on stats and GPU. [2010
paper](http://www.tandfonline.com/doi/pdf/10.1198/jcgs.2010.10016) titled
_Understanding GPU Programming for Statistical
Computation: Studies in Massively Parallel
Massive Mixtures_. I think I've looked at this before.

Other idea to work on for next week: Static code analysis. Get an example
script. _(done, can use a traffic simulator and analysis)_ Can we discover
which elements of the script can run in parallel? Use `codetools` and
`codedepends` to make a data structure somewhat like a nested list / graph:
```
(Exp 1, Exp 2)          <-- Can run in parallel
(Exp 3)                 <-- Uses result of Exp 1 and Exp 2
(Exp 4, Exp 5, Exp 6)   Depends on Exp 3
...

```

Note this will quickly become hierarchical. We should be able to hack
something together quickly though. First task is to analyze it using the
tools, build the structure. Next step would be to inject code to make
it parallel.
