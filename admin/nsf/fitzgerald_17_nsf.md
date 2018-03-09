Please write a 2-3 paragraph SUMMARY of your fellowship activities and major accomplishments within the last year.


This should be written for the public, and should address both the Intellectual Merit and the Broader Impact of your work.


Enter the summary below (1000-5000 characters) OR attach a one page document (1 page limit).

Broader Impact

- TA for 2 classes
- 20 blog posts
- tutor veterans center
- organized student seminar in Fall, student seminar now in 5th quarter
- SWC in Jan with Easton White, instructor training in March


Intellectual Merit

- Pems data analysis, shared on dash.
- Industry consulting data analysis
- Metaprogramming and code analysis software
- Springer paper with Matloff and Yancey  Encyclopedia of Big Data Technologies


I want to highlight two results:

__R in Hive__ `write_udaf_scripts` provides a massive speedup
with much less code complexity for two particular classes of problems with
large data:

- Applying a vectorized R function (one output for each row)
- Reduction based on grouping by one column (one output for each group)

This uses standard interfaces to allow R to process streaming data.  It
mainly integrates existing technology in a useful way that's compatible
with R's computational model, so it isn't really "new". This doesn't
analyze code, but it does generate code. The PEMS analysis demonstrates the
practical value of this.


__Column Use Inference__ `read_faster` analyzes code to
find the set of columns that are used and transforms the code to a version
that only reads and operates on this set of columns.


