Tue Feb 28 11:41:48 PST 2017

Looking to schedule the QE in June.

To prepare it's good to think about related ideas, so that one is ready to
answer questions when probed in the QE. For example, I'm mostly considering
forking, but it's good to also think about shared memory and SNOW clusters
as different platforms.

Currently I have constraints on the order in which the code blocks can run.
Duncan suggests to make this into a data structure that I can 
query and use to evaluate the code.

## Next steps, in approximate order:

- Motivating examples. BioConductor may have some good scripts.
- Actual parallel execution
- Synchronization. How do the threads rendezvous with the master and share
  variables?
- Data location and movement. How do we make it such that data stays as
  local as possible?

## Extended steps

- Collect timings and input metadata
- Use these for optimization, ie. don't run in parallel unless needed
- Different platforms, ie GPU and SNOW

Medium to long term this could be combined with the compilation work.
