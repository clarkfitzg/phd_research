


Mon Apr 24 09:58:41 PDT 2017

Starting this outline after Duncan's review of my prospectus draft and
email thread with Norm.

My current goals with the design document are:

- Clarify objectives of research, particularly how I'll interface and
  interact with other existing projects like iotools, data.table, and
  partools
- Improve examples

Outline:

- Introduction
- Simple Example
- Real Example
- Design Considerations / Issues
- Code Analysis
- Conclusion

Extra Examples

- Andrew Latimer's forest 'greenness' data, split by forest type, elevation and do
  regression based on pixel

What am I targeting?
Embarrassingly parallel ops and group by. But Spark and Hadoop already do
this. So is it a reimplementation of Map reduce? partools and distributed R
also similar.

Main points
============================================================

1. Sequential processing only goes so far
2. Several parallel strategies exist to improve performance
3. It's not known which will be best
4. Each one requires deeper knowledge of that particular technology
5. Therefore techniques to programmatically identify and use parallel
  patterns implicit in code would be valuable

Examples
============================================================

Listing the characteristics that make these interesting and relevant to
research.

## Sufficient statistics for exponential families

For iid rows of an `n x p` matrix `X`, compute the sufficient
statistics `T(X_i)`. Say for multivariate normal with `p = 1000`.

- Easily understood
- Relates to statistics
- Embarrassingly parallel row-wise operations

__Reservations__
These can get so specific. The numerically stable way to do this is to use
the updating formula.

## Prediction from a fitted model

Given a fitted model `f`, and an `n x p`  matrix `X`, compute 
`yhat_i = f(x_i)`.

- Easily understood
- Embarrassingly parallel row-wise operations

__Reservations__
When do we need to predict these super large objects? No examples come
immediately to mind. 

## PEMS robust regression

Perform iteratively reweighted least squares after grouping the data by
station.

- Realistic, interesting problem involving large data
- Not embarrassingly parallel because of initial data organization

Computational Strategies
============================================================

## Chunks


## Threads

- Shared memory

## Multicore

- Forking

## GPU

- Kernel functions
- Intermediate reductions

## Pipeline Parallelism

- MPI or sockets


Issues
============================================================
