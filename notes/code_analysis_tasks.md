Mon Feb 26 13:25:22 PST 2018

Following meeting with Duncan on Friday I'm writing down questions to
answer with code analysis.

Duncan's use case: people come him with code to make faster. They often
give him the whole data set which may take days to run. It would be neat to
look at the code and then artificially create a data set that is similar to
the large one. This must be similar to generated tests that aim to explore
every branch.

## Outcomes

What are the high level goals?

__Speed__

Take code that runs in 20 minutes and make it run in 10 minutes. There are
many ways to do this: detecting programming mistakes, compilation,
parallelism, dropping in more efficient implementations, etc.

__Memory__

Take code that requires 5 GB, and run it in a way that requires only 2 GB,
or even just 10 MB. This may be possible with streaming computations.

__Data Abstraction__

Take code that runs on a local data frame and evaluate it efficiently on
any tabular data source. The data could be a table in a database, a bunch
of files in a local directory, or a file on Amazon's S3.


## High level Questions / Tasks

Below "run" means evaluate a particular piece of code on a particular data
set.

__Cloud Computing__

If we pay for computation and storage then we can do things based on cost.
We have access to a potentially limitless amount of computing power.
Things we might like to do when evaluating a particular piece of code on a
particular data set:

- Minimize cost
- Minimize time
- Minimize cost such that the computation takes no more than `h` hours
- Minimize time such that the computation costs no more than `d` dollars


## Language independent semantics

The following code performs the same semantic operation:

```{R}
subset(flights, month == 1 & day == 1)      # Base R
flights[month == 1 & day == 1, ]            # data.table
filter(flights, month == 1 & day == 1)      # dplyr
```

Because the semantics are the same it should be possible to represent these
semantics in a way that's independent of the syntax. Indeed, if the rows
are unique the code above is
equivalent to [selection in relational
algebra](https://en.wikipedia.org/wiki/Selection_(relational_algebra) or
just a simple SQL query.

The more we know about the semantics of the desired operation the more we
can use this knowledge to evaluate the code in a different way. 

Can we capture the semantics of the query into an intermediate data
structure that's modular to the language? That would be super cool, because
we could optimize that object directly. We could translate it to and from
any language we like. The trouble I have with the rquery package is that
it's tied to tightly to R, when I see no reason for it to be.

This is really exciting to me.

This reminds me of the queries I saw at work that are represented with some
JSON.

Jake Vanderplas did something similar with [plotting in Python's
altair](https://github.com/altair-viz/altair) that implements plotting
based on the [Vega
specification](https://vega.github.io/vega/examples/bar-chart/).
So I'm thinking about a similar specification for data analysis.

It's also similar to LLVM providing a more modular framework for compilers.

Googling around here is some work that appears relevant:
https://arxiv.org/abs/1607.04197

What might it look like? It should be as close to SQL as possible.
Basically I'm thinking of it as machine readable SQL, or SQL that takes no
effort to parse.

```
{"query": {
    "FROM": "flights",
    "SELECT": ["a", "b", "c"],
    "WHERE": [
        ["=", "month", 1],
        ["=", "day", 1]
    ],
}
```

And then we want to be able to extend it, for example apply a user defined R
function (UDF) to one of the columns:

```

{"query": {
    "FROM": "flights",
    "SELECT": ["a", 
        {"UDF": {"language": R,
                "code": "function(x) x + 2",
                "vectorized": true},
        "SELECT": "x"
        "AS": "fx"
        }
    ]
}}

```

## data

We can represent metadata along with the data in a similar way. We can
build a data description that allows us to generate code that doesn't
require any inference. Granted, many packages do a great job at inference,
but we can generate more specific code and remove assumptions if we don't
have to do this inference.

WHOA- crazy idea. We could generate and use compiled code. Not sure that it
would be any faster than `iotools` or `data.table` though.

Suppose flights is a table in a text file. Here's what the metadata might
look like:

```

{"data": {
    "path": "/users/clark/data/flights.csv",
    "text": true,
    "delimiter": ",",
    "header": false,
    "column_names": ["day", "month", "a", "b", "c"],
    "column_types": ["INT", "INT", "VARCHAR(200)", "FLOAT", "BOOLEAN"],
    "rows": 10000,
}}

```


## Related

From the Python [Ibis docs](http://docs.ibis-project.org/design.html):

```
The main pieces of a SELECT statement are:
The set of column expressions (select_set)
WHERE clauses (where)
GROUP BY clauses (group_by)
HAVING clauses (having)
LIMIT clauses (limit)
ORDER BY clauses (order_by)
DISTINCT clauses (distinct)
```

So we would probably want to do all these things.


## More Technical

__Reorder code in an efficient way__


- What columns to we need?
- What subsets of the data do we actually need?

If these are known early then we can filter the data early, even at the
source. This saves memory and time for intermediate computations.
