First [install ripser](https://github.com/Ripser/ripser).

Then make it locatable on your system `PATH`, something like:
```
$ ln -s /home/clark/dev/ripser/ripser /usr/local/bin/ripser
```

After this your system should be able to find `ripser`:
```
$ which ripser
/usr/local/bin/ripser
```

Now you can do something like this in R:
```R
# Operate on a data point cloud represented as a matrix
m = matrix(c(1,0,
             0,1,
             -1,0,
             0,-1)
           , byrow = TRUE, ncol = 2)

# Ripser likes to read files in, so use a temporary file
f = tempfile()
write.table(m, f, col.names = FALSE, row.names = FALSE)

output = system2("ripser", args = c("--format point-cloud", f)
        , stdout = TRUE)
```

`output` is a character vector in R which needs to be parsed to perform any
analysis.
