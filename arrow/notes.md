## Ideal case

> Suppose we have nice R / Arrow bindings and everything works out perfectly.
> What then? What's the ideal state of affairs?  

Here's the dream:

Arrow allows R to interface with existing big data systems. Then we take a
Spark cluster with terabytes of data stored in memory and efficiently run R
code on that data. Spark does the preprocessing and splitting while R
operates under its normal in memory model on the pieces.

The analyzed R code allows pushing computations into an underlying library.
For example:

```
d = load("huge_data.parquet")
d1 = d[, 1]
d68 = d[, 68]

diff = d1 - d68
```

Then this is capable of only loading the necessary columns. Moreover, the
code analysis detects vectorized operations and automatically does them in
parallel based on the chunked structure of the data. This parallelism also
translates directly into serial chunk based operations that allow R to work
efficiently on out of memory data.

Using an Arrow data frame also provides a nice way forward to put
data frame oriented computations onto the GPU. The recently organized 
[GPU Analytics Initiative](http://gpuopenanalytics.com/) is working towards
building the prerequisite software infrastructure, and their specifications
are based on a subset of Arrow.

> What's the research question, and how does it relate to my current focus?

My current research question is essentially: given code, data, and a
system, how can we transform the code to run efficiently on a particular
system?

Then the research goal with Arrow is to demonstrate a system capable of
interfacing R with data provided by other systems and possibly other
languages. Success means being able to do this with more efficiency and
less code than would be needed otherwise. In other words, it's more general
than a connection from R to any particular system.

## Risks

It will likely take months to produce decent bindings. This is time that
can likely be spent more productively in other avenues of research. My lack of
experience in C++ does not help matters.

Different approaches may not make it into the official Arrow codebase. Ie.
Wes would rather use Rcpp and write bindings by hand vs. automatically
generated bindings.

Arrow may not be well adopted. For example, Spark doesn't yet support
Arrow.

If everything is adopted and becomes popular then maintenance will require
time and energy on my part.

There's very little publicly available data in Parquet. I see Parquet more
as something that a larger organization chooses for an analytics focused
Hadoop cluster. Parquet does not help an independent academic researcher
relying on text data.

## Conclusions

The inherent splittability of Parquet and Arrow is a large part of the
appeal. But plain text files are also splittable, and the `iotools` package
by Arnold, Kane, Urbanek provide high performance tools to read and assist
with this splitting. I can get deeper into the code analysis faster by
taking regular R code and mapping it into equivalent iotools code.

Arrow is a peripheral task. It seems much less risky at the moment to
focus on the research activities that will lead to my PhD. Once I have
something more tangible in terms of research I could pick this up again.
It would certainly be helpful for me to learn the details of data storage,
C++, and R's C API. Doing this project would also help with employment
afterwards, say as a data engineer.

## Background

Julien LeDem wrote a [nice blog
post](http://www.kdnuggets.com/2017/02/apache-arrow-parquet-columnar-data.html)
that explains the advantages of a columnar data representation and gives
some background for the differences between Parquet and Arrow.  
Some key points:
- Overhead often dominates the total computational time.
- Columnar formats have significantly less overhead than row based formats
  for most data analysis tasks.
- Parquet and Arrow both provide standardized formats for columnar data
- Parquet is for storage on disk while Arrow is for representation in
  memory.
