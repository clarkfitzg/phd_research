Fri Jul 14 10:04:54 PDT 2017

## Background

Julien LeDem wrote a [nice blog
post](http://www.kdnuggets.com/2017/02/apache-arrow-parquet-columnar-data.html)
that explains the advantages of a columnar data representation and gives
some background for the differences between Parquet and Arrow.  
Some key points:
- Overhead can dominate the total computational time.
- Columnar formats have significantly less overhead than row based formats
  for most data analysis tasks.
- Parquet and Arrow both provide standardized formats for columnar data
- Parquet is for storage on disk while Arrow is for representation in
  memory.


## A Use Case

I'm working on processing data that won't fit in memory. Therefore the data
must be divided into subsets where each subset fits in memory for part of
the computation. Dividing into subsets also facilitates parallel computing.
I can write all the splitting logic myself, but this is slow and error
prone. A better approach is to integrate with existing powerful tools.

More generally I would like to see R interact better with larger systems.


