Thu Mar 15 10:51:29 PDT 2018

This is to summarize the idea of statically analyzing an entire general R script to
incorporate what we might call "fork-join" parallelism. We start with a script
and build it into something that uses the most parallelism it can.
The audience is someone familiar with R and parallelism, ie. Norm Matloff.

There are a few components or layers of complexity to this.

1. Represent the execution dependency order in the script as a DAG.
2. Rewrite the code / change the computations
3. Minimizing data transfer
4. Revisit intermediate data on worker nodes


##


## Scratch

Actually the revisiting data idea might be very helpful on a GPU.

The only difference between these two examples is that one is eagerly
evaluated, and one is lazily evaluated:

```{R}
# Example 1:
h(f(), g())

# Example 2:
a = f()
b = g()
h(a, b)
```

If the parallelism happens only at the expression level then we can get the
parallelism for Example 2, but not for Example 1. We could expand this
recursively by examining the bodies of these functions
