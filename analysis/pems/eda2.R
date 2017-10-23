Mon Oct 23 14:49:23 PDT 2017

Meeting with Michael Zhang tomorrow, so I want to revisit the data to think
about what we can do with it.

```{R, echo = FALSE, eval = FALSE}

rmarkdown::render("eda2.Rmd", "html_document")

```


```{R}

stations = read.csv("station_cluster.csv")

```

Plot the histograms for the slopes and intercepts by themselves.

```{R}

par(mfrow = c(2, 2))

vars = names(stations)[3:6]

lapply(vars, function(varname) {
    hist(stations[, varname], main = varname, xlab = "mph")
})

```

Some have a positive congested slope. I don't know what that means.

```{R}



```
