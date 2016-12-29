Do basic computations in R like `+` for vectors use BLAS? No, they need to
handle NA's. It's done explicitly in the C code `arithmetic.c` which loops
through each pair of elements in two integer vectors and calls `R_integer_plus`
which handles `NA_INTEGER`. But where is `NA_INTEGER` defined?
In `include/R_ext/Arith.h` we see the line:
```
include/R_ext/Arith.h:#define NA_INTEGER        R_NaInt
```
along with a comment that says R_NaInt is the minimum integer. in
`arithmetic.c` we see the line setting it to `INT_MIN`, the C language
constant.


GPU programming with OpenCL seems to require a lot of boilerplate. Could we
generate this and / or simplify execution on GPU?
