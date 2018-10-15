Tue May 22 08:10:57 PDT 2018

Short term

- Some of the basics are working, now we need realistic examples.
- The current SNOW / socket code generation approach seems reasonable.
  Or at least not obviously crazy. We'll see if it works for larger examples.

Longer term

- Dimension and object size inference will allow us to estimate how long it
  will take to execute the code and send objects without actually running the
  code. Start with some initial data size and propagate it through.
- Think about how to generalize from a single computer with multiple
  processors to multiple computers connected by a network with
  heterogeneous latency and bandwidth.
