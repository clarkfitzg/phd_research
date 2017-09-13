This documents a tentative plan for dissertation work.


## 1 Code Analysis and Parallelism

Research goals:
- Detect and automatically use parallel patterns in code
- Put the execution of R code into a numerical optimization
  framework, where wall time is the quantity to minimize

Parallel patterns may include:
- `apply` type calls (easiest)
- task parallelism (requires more code dependency analysis)
- pipeline parallelism (useful for larger than memory)

`autoparallel` will be the primary software result to come out of this.


## R on GPU

Research goals:
- Compile kernels from R code and run them on a GPU
- Better understanding of when and how to use GPU for data analysis


## R in databases

Research goals:
- "Bring the code to the data"
- Model to efficiently scale up computations

Assume that large data is stored in some larger system, hopefully in an
efficient format. This applies more to large organizations, and less to
academic researchers who typically use smaller files.

The main use case I have in mind is `group by`, aka the divide and
recombine paradigm. This lets one keep R's regular vectorized model on
small subsets of the data.

Another goal is to have something that bridges the gap between what can be
done on a single server and a 


## Cloud computing

Research goals:
- How cheaply can we do some data processing task? Make it real with Amazon.

This could even be done dynamically using numerical optimization- check
programmatically if prices drop below a certain level and then run it.  See
what it's like for data stored in Simple Storage Service (S3) or Elastic
Block Storage (EBS).  Elastic map reduce (EMR) with
S3.

Compare performance among Azure, Google.

Consider code development time also.

An efficient data format like Parquet becomes very helpful in this context,
since it takes less space and loads faster.
