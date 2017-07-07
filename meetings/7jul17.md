Fri Jul  7 10:46:34 PDT 2017

## Interactive use case 

Talking with Duncan about one way that automatic parallelization would be
useful for interactive work. 7 minutes is too long.

- Building software on the fly, changing functions, etc.

A simplified problem is to look at `lapply` on lists. In this use case
`docs` is a list of documents that takes time to process.

Base R:

```
lapply(docs, findtitle)
```

Parallel R:

```{R}

# Start a cluster and distribute the list.
cl = makeCluster(2)


```
