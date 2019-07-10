Tue Jul  9 15:02:42 PDT 2019

Notes as I install RCIndex package again.

Using version 3.8 for Mac and following the INSTALL.md notes file.

From the RCIndex top level directory
  CLANG_LIB
  CLANG_INC

```

export CLANG_DIR=${HOME}/Dev/ClangLLVM/clang+llvm-3.8.0-x86_64-apple-darwin/
export CLANG_INC=${HOME}/Dev/ClangLLVM/clang+llvm-3.8.0-x86_64-apple-darwin/include/
export CLANG_LIB=${HOME}/Dev/ClangLLVM/clang+llvm-3.8.0-x86_64-apple-darwin/lib/

./configure

R CMD INSTALL .

cd ~/dev/RCIndex/inst

```

In R now, checking if I can do anything.


```{r}

library(RCIndex)

f = getFunctions("~/dev/RCIndex/inst/exampleCode/fib.c")

source("~/dev/RCIndex/inst/exampleCode/funPointer.R")

```

Nope, segfaults.

