Wed Dec  6 09:33:05 PST 2017

# Canonical Form

Storing code in some uniform representation may help with determining
how to parallelize it.

What do I want to represent? How about a DAG representing the data flow for
the whole program. This relates to what I had before. It could be augmented
by annotating each function with being a `map` or `reduce` operation. Or
the function could be neither, just producing something new and different.

We can then compose `map` functions in parallel, which is something like
loop fusion.

Here's one example program

```{R}
x = genx()
y = f(as.integer(ceiling(x)))
z = mean(x)
fzy(z, y)
```

The idea in constructing this DAG is:

- determine whether it's worth it go parallel based on the overhead
- "fuse" nested map calls into parallel versions
- see where parallel tasks exist

![](program.svg)

Nodes represent functions. We annotate them with a type (TODO: better word)
`t`, with the following meanings:

- `map` apply the same operation to many elements
- `reduce` reduce from size `n -> 1`
- `general` does something other than map or reduce

The cost attribute on the node represents cost as a function of the number
of elements `n`.

Arrows represent the data flow, each arrow is a piece of data.

- `n` is the number of elements
- `size` is the size of each element in bytes, ie. 8 bytes for a double
  precision number.
