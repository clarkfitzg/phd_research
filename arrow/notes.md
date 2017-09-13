Tue Sep 12 17:29:48 PDT 2017

What can I do with what currently exists in Arrow? I'd like to be able to
do a fast parallel group by type operation. Suppose that I start off with a
partitioned Parquet dataset. From `pyarrow` I would load this with
`pyarrow.parquet.ParquetDataset` which would give me `pyarrow.Table`. This
gives me fast access to the columns and conversion into a pandas data
frame, but doesn't help with parallel group by.

TODO: Come back here


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

> What can we do with R / Arrow that's qualitatively new?

The plasma store provides a way for multiple processes to operate on the same
data. This is similar to the following R packages:

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

> One of the goals of Apache Arrow is to serve as a common data layer
> enabling zero-copy data exchange between multiple frameworks.

[August 17 blog post](https://arrow.apache.org/blog/2017/08/08/plasma-in-memory-object-store/)

## Related work

`bigmatrix` has a memory mapped matrix.

`LaF` provides access and data processing to CSV and fixed width text files
possibly exceeding memory.

`ff` provides "memory-efficient storage of large data on disk and fast
access functions". Further:

> ff files can be shared by multiple ff R objects (using different data
> en/de-coding schemes) in the same process or from multiple R processes to
> exploit parallelism.


## pyarrow

## Feather

In 2016 Hadley Wickham and Wes Mckinney released Feather, a file format and
software implementation to serialize data frames compatible between R and
Python. One [design goal](https://blog.rstudio.com/2016/03/29/feather/) was
that operations on Feather objects should be fast enough that the disk is
the limiting factor, or in other words be IO bound.

Many of the benchmarks I've observed take the median time to read and write
without flushing the hard drive cache. This means that they measure time to
load to and from memory, when usually the goal is to measure the time to go
to and from disk.  Actually, most data science workflows probably care most
about how long it takes to load from disk and how long it takes to write to
memory. We're typically not writing files larger than memory, so we can
afford to let the OS physically write the pages out at it's own convenience.
