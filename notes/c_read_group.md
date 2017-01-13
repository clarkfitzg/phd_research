## Fri Jan 13 09:17:21 PST 2017

I was interested in how R handles NA's so I looked through the source code
just to see the simple case of integer addition. In `src/main/arithmetic.c`
there's this code which I 'd like to understand.

```
308 #define R_INT_MAX  INT_MAX
309 #define R_INT_MIN -INT_MAX
310 // .. relying on fact that NA_INTEGER is outside of these
311
312 static R_INLINE int R_integer_plus(int x, int y, Rboolean *pnaflag)
313 {
314     if (x == NA_INTEGER || y == NA_INTEGER)
315     return NA_INTEGER;
316
317     if (((y > 0) && (x > (R_INT_MAX - y))) ||
318     ((y < 0) && (x < (R_INT_MIN - y)))) {
319     if (pnaflag != NULL)
320         *pnaflag = TRUE;
321     return NA_INTEGER;
322     }
323     return x + y;
324 }
```

Users have expressed interest in marking different types of missing values
for different reasons, ie. not recorded, lost, etc. Is there a way to make
this extensible?

## Wed Jan 11 10:09:29 PST 2017

Observing a strange thing: I can take the exact same C code
- ~8 seconds for the operation of interest when I run the executable from command line. Call this the pure C version
- ~3 seconds to run from within an R library

I think it may be using different versions of math functions like `log()`

[Code and
notes](https://github.com/clarkfitzg/fastgauss/blob/master/tps/Ctps/Makefile)

Mon Jan  9 09:40:53 PST 2017

What's the best practice to write C to be portable when binding to one
language?

It must be generally better to write the core functionality using
only std libraries in C and then write a separate binding / wrapper using
language specific tools ie. `REAL(x)` in R to extract underlying array of
doubles from `SEXP`.

For numeric work is it better to pass by reference? This allows the higher
level language to manage memory, which does two things:
- No need to integrate garbage collection
- Avoid allocating memory
