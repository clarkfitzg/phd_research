Fri May 19 09:34:10 PDT 2017

Working through install problems.

```
** testing if installed package can be loaded
Error in dyn.load(file, DLLpath = DLLpath, ...) :
  unable to load shared object '/usr/local/lib/R/site-library/RSQLiteUDF/libs/RSQLiteUDF.so':
  /usr/local/lib/R/site-library/RSQLiteUDF/libs/RSQLiteUDF.so: undefined symbol: sqlite3_enable_load_extension
Error: loading failed
Execution halted
ERROR: loading failed
```

This means that the symbol `sqlite3_enable_load_extension` cannot be found.
Googling a bit leads me to believe that perhaps the version of sqlite3 on
my machine was not compiled with support for the extension functions. So I
download, compile and install sqlite3 from source.

Now the loader should be using this version of sqlite3:

```
$ ldconfig -p | grep "sqlite"
        libsqlite3.so.0 (libc6,x86-64) => /usr/lib/x86_64-linux-gnu/libsqlite3.so.0
```

Looking in the source object file shows that the symbol
`sqlite3_enable_load_extension` is indeed exported:

```
$ nm -D /usr/lib/x86_64-linux-gnu/libsqlite3.so | grep "enable_load"
0000000000028350 T sqlite3_enable_load_extension
```

So this particular source object file is not being used when RSQLiteUDF is
loaded. 
So the problem must happen during linking. Lets try to explicitly link
against the correct library.

```
R CMD SHLIB -o src/RSQLiteUDF.so src/Rinit.c -L/usr/lib/x86_64-linux-gnu -lsqlite3
R CMD INSTALL .
```

OK, that works. Took me a while to get the linker command right.


# Unnecessary steps

I can duplicate the load error
from an R terminal:

```
> dyn.load("src/RSQLiteUDF.so")
Error in dyn.load("src/RSQLiteUDF.so") :
  unable to load shared object '/home/clark/dev/RSQLiteUDF/src/RSQLiteUDF.so':
  /home/clark/dev/RSQLiteUDF/src/RSQLiteUDF.so: undefined symbol: sqlite3_enable_load_extension
```

What happens when I load the one I want first, and then try? Same error:

```
> dyn.load("/usr/lib/x86_64-linux-gnu/libsqlite3.so.0")  # Works fine
> dyn.load("src/RSQLiteUDF.so")
Error in dyn.load("src/RSQLiteUDF.so") :
  unable to load shared object '/home/clark/dev/RSQLiteUDF/src/RSQLiteUDF.so':
  /home/clark/dev/RSQLiteUDF/src/RSQLiteUDF.so: undefined symbol: sqlite3_enable_load_extension
```

