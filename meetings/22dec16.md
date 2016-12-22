Thu Dec 22 14:58:08 PST 2016

Spoke this morning about keeping a running research log.

The next thing to do is go through the whole though process, create a
chatty narrative for what things I'm trying.

Good to incrementally build up documentation and notes as I do the research
process. Then Duncan can also see my thought process and help keep me on
the right track.

An abbreviated example:

With Irene's Ripser project, I considered replacing `std::cout
<<` with an object that could collect the output and return it to R. But I
rejected this idea since it's a bit of a hack, and for this simple
application it makes more sense to just use a call to R's `system2()`.
More generally this brings up the question of how to bind into programs
which are only meant to be used on the command line.
