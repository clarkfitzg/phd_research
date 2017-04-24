Mon Apr 24 09:58:41 PDT 2017

Starting this outline after Duncan's review of my prospectus draft and
email thread with Norm.

My current goals with the design document are:

- Clarify objectives of research, particularly how I'll interface and
  interact with other existing projects like iotools, data.table, and
  partools
- Improve examples

Main points
============================================================

- Several strategies exist to improve performance.
- It's not known which will be best.

Examples
============================================================

Listing the characteristics that make these interesting and relevant to
research.

## Prediction from a fitted model

- Easily understood
- Embarrassingly parallel row-wise operations

## PEMS robust regression

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
