Tue Oct 25 11:58:56 PDT 2016

Met with Nick to get a basic overview of the goals of R compilation and
learn where he's at in his research.

For the past year Nick has been mostly working on type inference
for R- call it Type Inference V1.
The basic idea is to look at the parse tree for a bunch of R code and use
this to infer the types of all variables. This information is then given to
the compiler to generate machine code that performs the same operation.

This needs to correctly handle `if` statements that may do things like:

```
if(x < 3){
    x = 2
} else {
    x = "hello"
}
```

Other challenges include breaking from `for` loops.

There were some difficulties with the initial approach:

- One type per variable doesn't handle dynamic assignment which changes
  class
- Control flow not directly represented
- S3 class system not ideal for representing data, ie. `compile.if,
  compile.for, compile.call` handling `return()` as if it were a normal
  function call.
- No references / functional programming style made it difficult to
  manipulate the abstract syntax tree (AST)
- Not possible to directly get parent of a node

Nick is now working on Type Inference V2 using a
[Hadley-Milner](https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system)
type system.

- Custom tree data structure represents AST
- Uses Winston Chang's R6 reference classes
- SSA (single static assignment) creates new variables `x#1, x#2, ...` as `x`
  is assigned to new values.

Duncan notes- There needs to be some separation between what the type
inference does and what the compilation package does. Ideally the
functionality doesn't overlap.

## Possible projects

- Use Nick's AST data structure to detect opportunities for parallelism.
  This could be done in the R language.
- Similar code analysis for the C code could bring in the minimal set of C
  code necessary to make the machine instructions that can run outside of
  the R interpreter. This would build off of the
  [RCIndex](https://github.com/omegahat/RClangSimple) package. Nick hasn't
  looked at analyzing C code.

## Miscellaneous

Oracle's Java based [fastr](https://github.com/graalvm/fastr) implements R
and is probably the most similar project. From their website:

> FastR is an implementation of the R Language in Java atop Truffle and
> Graal. Truffle is a framework for building self-optimizing AST
> interpreters. Graal is a dynamic compiler that is used to generate
> efficient machine code from partially evaluated Truffle ASTs.

Would Karl Millar's Rho project be a nice way to analyze and bring in C
code?

Book recommendations: 

- "Algorithm Design Manual" explains trees and related concepts.
- "Optimizing Compilers for Modern Architectures" talks about detecting and
  using parallelism
