Thu Mar  1 08:26:32 PST 2018

Nick and I spoke yesterday about his idea of converting code from the AST
into a "flat" data structure.

```{R}

x = 


```

Potential advantages of this approach:

- Easier to keep a corresponding data structure that holds other information
  related to the code that we would like to track, for example output
  dimensions or timing information.
- Flattened structure removes control flow, so there are fewer special
  cases to handle.
- Finer control if we allow eager evaluation of promises.

Talking it through with Nick we realized that to capture the task
parallelism that comes from the use-definition chain we need an actual
graph structure, possibly in addition to the flat data structure. If we
need this graph anyways then we potentially run into the same problems that come
from maintaining two corresponding data structures. 

The graph can probably be computed from the flat data structure, but then
we'll want to permute it.
