Mon Mar  5 08:59:05 PST 2018

Thinking about the column selection stuff I did in the fall. I can generalize
this to include row filters as well.

The general principle is that we would like to infer from the code that
only a subset of the rows and columns are necessary. 
The motivation for this is that R can't load data sets that are larger than
memory. Somewhere I heard the quote: "The most important performance
optimization is going from non-working to working". So we're working on
this most important optimization.

The other thing to realize is that databases work extremely well for these
types of operations. Rather than reimplement databases in R we can
partition the work in a way that makes sense.

The easiest possible case is the following:

```{R}
iris = read.csv("iris.csv")

iris = subset(iris, Species == "setosa", c("Sepal.Length", "Petal.Width"))
```

This is easy for a few reasons:

- The 2nd assignment immediately writes over the original data, so the
  program can't possibly use the original data.
- All column and row filters are contained within `subset()`, so we only
  need to analyze one statement.

Here's a more general version:

```{R}
iris = read.csv("iris.csv")

species_of_interest = "setosa"

iris2 = subset(iris, Species == species_of_interest, c("Sepal.Length", "Petal.Width"))
```

In this case we need to know that the remainder of the script doesn't use
the full data in `iris`. We also need to chase down the
`species_of_interest` variable. This will fail if it's not a literal in the
code.

When I do this I often filter a data set down in several steps with
intermediate variables. For example:

```{R}
iris2 = subset(iris, Species == species_of_interest)
iris3 = iris2[, c("Sepal.Length", "Petal.Width")]
...
```

We need to capture this use case too.

## Code Analysis

The task then is to statically analyze the code to discover which subset is
necessary. In the fall I did the columns in a somewhat ad hoc way. To do it
comprehensively I need to account for assignments to new variables as
described above. Also I should separate the data read step- that is
something different.

__Inputs__

- R script, with every statement strictly necessary.
- Final output?

__Outputs__

- Character vector of necessary columns
- Symbolic computations on columns
