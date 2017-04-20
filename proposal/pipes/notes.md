Mon Apr 17 15:58:27 PDT 2017

Amazingly, this approaches the theoretical limit for speeding things up,
going from about 13.5 to 7.5 seconds.

```
$ time make Y.txt
Rscript predict.R 1000 2000000 5 X.txt Y.txt

real    0m13.582s
user    0m10.568s
sys     0m3.224s


$ time make Y2.txt
Rscript step1.R 1000 2000000 5 X.txt Y2.txt &
Rscript step2.R 1000 2000000 5 X.txt Y2.txt

real    0m7.692s
user    0m4.640s
sys     0m3.092s


$ time make Y2.txt
Rscript step1.R 1000 2000000 5 X.txt Y2.txt &
Rscript step2.R 1000 2000000 5 X.txt Y2.txt

real    0m7.787s
user    0m4.800s
sys     0m3.012s

```

10000 is slower than 1000.

```
$ time make Y2.txt
Rscript step1.R 10000 2000000 5 X.txt Y2.txt &
Rscript step2.R 10000 2000000 5 X.txt Y2.txt

real    0m9.863s
user    0m5.440s
sys     0m4.472s
```


When I do three they still work. It would be interesting to measure the
overhead vs performance gains in this approach. It may or may not scale
well. What about a prototype that can take in code and generate this
parallel code? This might be a nice intermediate result.

```

$ time make Y3.txt

Worker 1 connected
Worker 3 connected
Worker 2 connected

real    0m8.023s
user    0m3.564s
sys     0m3.652s

```

# Design

We can first think about is required for this to work. Some objects
must be created at the source, and at the sink. This is the setup code, and
it should run before this worker begins to accept data.

```
fX = file(INFILE)
open(fX)
```

Then there's code to clean up after the job is complete.

```
close(fx)
```

Then there's the code which actually processes the data, handing it off to
the next worker:

```
X_i = scan(fX, what = colclasses, nlines = CHUNKSIZE, quiet = TRUE)
X_i = data.frame(X_i)
serialize(X_i, s_out)
```

Here `CHUNKSIZE` is the important tuning parameter which controls
the data sizes flowing through. How much does it matter?

This could be captured through a function:

```
readone = function(){
    X_i = scan(fX, what = colclasses, nlines = CHUNKSIZE, quiet = TRUE)
    data.frame(X_i)
}
```

Generally, this function needs to produce a special sentinel value when the
job is complete. And there should be some way to stop failing pipelines.

One idea for a sentinel:

```
> data.frame(scan("nothing.txt", what = list(1, 2, 3)))
Read 0 records
[1] numeric.0.   numeric.0..1 numeric.0..2
<0 rows> (or 0-length row.names)
```
But this 

