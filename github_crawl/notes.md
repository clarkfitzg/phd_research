Fri Jan 12 10:37:04 PST 2018

Attempting to get a larger corpus of R code here.

One approach is to only look at gists for people who are conspicuous R
users.

I'm interested to see how people actually use R for data analysis work.
Packages are less interesting because they typically just contain tools.
Vignettes are interesting, and CRAN vignettes have the advantage of
requiring that the code actually works. A disadvantage is that the package
must be installed.

Jan Vitek's group has a Docker image with all the R repositories.
https://github.com/PRL-PRG/docker-r-full

They also did a map of source code duplication in Github repos requiring a bunch of
downloads: http://janvitek.org/pubs/oopsla17b.pdf
Cool stuff.

Just messing around searching for my username- I found this repo:
https://github.com/adamtclark/tradeoff_model. This is interesting because
it has a bunch of R code that is not a package. It reminds me of Scott's
code- highly repetitive. Github marks this as an R repository. So lets try
to find all R repositories, download them, and then we can check to see
which ones are valid packages.

Tue Feb  6 16:18:07 PST 2018

`RMySQL` and `RPostgreSQL` are popular. What do people do with them?

Checking to see how people actually use `parallel` out in the wild.

Of the repos that I downloaded these ones use parallel:
- `BRC_SingleCell_LJames`
- `DBDA2Eprograms`
- `DBDA2E-utilities`
- `gpseq-seq-gg`
- `MetaAnalysisJaegerEngelmannVasishth2017`
- `seq-lib-gg`


`BRC_SingleCell_LJames` appears to be reasonably well organized. They seem
to use some standard comments at the top- something like this would be very
helpful in generating a project description.

> Analysis of Single Cell sequencing data

The parallel code is pretty repetitive.

```{sh}

grep "mclapply" 16.2_signatureGenesCellTypes.R -B 1 -A 2 | wc -l

mCombinations = combn(paste('X', cvTopGenes, sep=''), 1)
lFits.1var = mclapply(1:ncol(mCombinations), function(iIndexSub) {
  tryCatch(tryCombinations(iIndexSub), error=function(e) NULL)
})
--
mCombinations = combn(paste('X', cvTopGenes, sep=''), 2)
lFits.2var = mclapply(1:ncol(mCombinations), function(iIndexSub) {
  tryCatch(tryCombinations(iIndexSub), error=function(e) NULL)
})
--

# Essentially the same thing 22 more times at different points in the file.

```

I wonder if the author wrote this all at once or it grew organically?

## Reduce

Summary: Most of the code using `Reduce()` does some form of `Reduce(merge, ...`
which is the same as joining several tables together in SQL. But it isn't
optimized.

`data.table` doesn't seem to offer a function for this:
https://stackoverflow.com/questions/13273833/merging-multiple-data-table

A bunch of other code does `Reduce(rbind, ...`, which performs far worse
than just calling `rbind(...`. So the users probably just don't know this.

The `Reduce(intersect, ...` is a nice example, would be useful to teach in
a class.

Now looking at those repos that use `Reduce()`.
- `CrossU01_exRNA_Manuscript2017`
- `derfinder`
- `ehR`
- `Federal-IT-Dashboard`
- `preparer`
- `pullreqs-contributors`
- `satp`
- `supr`
- `tcgar`

`CrossU01_exRNA_Manuscript2017`

```
read.count.combined <- Reduce(function(...) merge(..., all=TRUE),
sapply(seq_
```

`derfinder` This is an RNA-seq processing
package. It uses `Reduce()` in one place:

```
int2 = function(z) Reduce('intersect',z) # need to take intersection of
more than 2 sets --      this is how you do it.
```

`ehR` package

```
$ grep -r "Reduce("
R/multi_merge.R:  multi_merge_fun <- function(x, key_var)
{Reduce(function(x, y) {x[y, on=c(key_var),
```

`Federal-IT-Dashboard` analysis:

```
Reduce(function(x, y) merge(x, y, all=TRUE),
```

`preparer` appears to be someone just messing around with package creation,
ie. only 77 lines of R code.
It seems like they just don't know how to use `rbind()`.

```
  xx = Reduce(function(df1,df2) bind_rows(df1,df2), xx) # stack them up
```

`pullreqs-contributors` contains the first interesting version of
`Reduce()`:

Staring at this it seems like just some fancy and inconvenient way to make a table.

```

# Extract all unique codes from the answer list
tags <- function(data) {
  unique(unlist(data[,-1]))
}

# Clark: Code below was inside another function. I'll add some dummy data here
data = data.frame(letters, letters, seq(length(letters)))
num.cols = 2

data <- subset(data, data[,1] != '')

tag.freq <- Reduce(function(acc, x){
  tag.counts <- Reduce(function(acc, y) {
    # If an error occurs, this means that the processed tag does not exist in
    # the processed column
    count <- tryCatch({nrow(subset(data[,-1], data[,y] == as.character(x)))},
                      error = function(x){0})
    perc <- tryCatch({(count / length(data[,y])) * 100},
                      error = function(x){0})
    rbind(acc, data.frame(tag = as.character(x), rank = y - 1,
                          val = count, perc = perc))
  }, c(1: num.cols + 1), data.frame())

  rbind(acc, tag.counts)
}, tags(data), data.frame())

```


`satp`

```
R/satp_clean.R:geo_matches <- Reduce(function(...) merge(..., by = c("record"),
```

`supr`

```
 70     out.points <- Reduce(spatstat::superimpose, mapply(function(p, ll) {
 71       spatstat::marks(p) <- cbind(spatstat::marks(p), ll)
 72       p
 73     }, spoints, ll, SIMPLIFY=FALSE))
 74

They also use map reduce in a direct way:

    out <- Reduce(rbind, mapply(function(p, ll) {

```

`tcgar`

```
    out <- Reduce(function(df1, df2) merge(df1, df2, by="panel"), counts)

```


