Wed Nov  8 09:46:59 PST 2017

Now that I've been working a bit with Hive / Hadoop I can see some of the
benefits. It's getting me serious speed ups, from days to minutes. It seems to
work well for the high throughput jobs that Hadoop was designed for.
Latency is generally poor, as with all Hadoop applications.

Writing now thinking about what kind of software to produce. I have in mind
an `rhive` package, kind of following the naming convention for the Hadoop
ecosystem as found in [Revolution
R](https://github.com/RevolutionAnalytics). This would become a package to
put on CRAN and talk about next summer at JSM.

What does the software need to do? Much of the requirements can be
discovered from [my blog
post](http://clarkfitzg.github.io/2017/10/31/3-billion-rows-with-R/).

I'm thinking of supporting two use cases:
- Vectorized data frame transformations, ie. `f()` on k rows produces k rows of
  output.
- data frame aggregations, where `f()` on k rows produces 1 row of output.

The main idea is that the user has some function to apply, and this
software applies it within Hive. Code generation makes it happen.

I can test it on my use case. My research goal is to do it all
automatically, but to do that I need this in place first.

Secondary things:

- Query the schema from the table. Requires a connection to the database.

__Inputs:__

Must have:

- `f` function that takes in a data frame and outputs a data frame.

More flexible:

- `group_column` name of the column to use to group by.
- `chunksize` 
- `input_sql` sql query defining the input data. Might be possible to infer
  this from script or function, if the function uses column names.
  Otherwise it might be a `SELECT *`. To start with it's best to have a
  script or string.
- `hive_params` explicitly set parameters in Hive. How to write the data,
  etc.
- `try` fail silently or not?.

Optional:

- `self_contained` worker nodes may or may not have the `rhive` library available.
  If they don't then we can send the code that we need, or send the library
  as a tarball or something.

__Outputs:__

- SQL and R scripts to do the transform.
- Can actually execute it on Hive, ie. call `$ hive -f mytransform.sql` through
  `system()`.

## Ideas

Will there be a speedup from using a fast file reader? Possibly not much if
we already know the schema, since we can skip column type inference.
