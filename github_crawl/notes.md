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
