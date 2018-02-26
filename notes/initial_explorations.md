## Notes for the next meeting

Tue Oct 18 17:16:07 PDT 2016

Did some interesting programming on the transportation data- stream models
for data processing in Python.  Equivalent to iterating over a file line by
line and performing data operations. If R could do this it would be similar
to the "sequential backend" that has been discussed in the distributed
computing working group.

Have been thinking about ways to visualize the [traffic
data](http://anson.ucdavis.edu/~clarkf/) and getting
started using Python's Bokeh / JS libraries. First thing to do is look at
changes in flow for eastbound and westbound traffic over time. Ethan had a
nice suggestion to look at the Fourier transform.

Thinking about what is missing in my data analysis toolkit now. I could use:

- More specific tools to process large data sets as a stream
- easier tools for visualization involving animation

These two could potentially be linked together, with a stream as an input
to the animation.

## Interesting other things:

Henrik Bengtsson [future package](https://cran.r-project.org/web/packages/future/vignettes/future-1-overview.html) in R.
Asynchronous execution provides an interesting possibilities for doing parallelism.

[Rstudio people](https://github.com/rstudio/tensorflow) are working on
[tensor flow](https://www.tensorflow.org/). I wonder if this could somehow
be extended to power R transparently to the user.
