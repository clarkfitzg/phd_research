Tue Nov  8 17:06:25 PST 2016

Interesting project to look into is openCV, stands for computer vision. We
could generate bindings for this. But be mindful of anyone who may be
working on this in R, try to collaborate.

Spent time this afternoon walking through code generation used in `poppler`.

Currently there is a problem with RCodeGen and RCIndex generating the
correct R generic and methods for C++ methods which have the same name but
different number of arguments, ie. 
```
void Square::move(int x) { ... }
void Circle::move(int x, int y, int z) { ... }
```

RCodeGen needs to be able to write function pointers as arguments.

Look into possibilities for code reuse with Rcpp. Can we use their C++ code
generation?

Tue Nov  8 09:57:44 PST 2016

High level direction for QE: Focus on code analysis as a basic topic.

Work on code generation now through Rcodegen. Use
[Rpoppler](https://github.com/dsidavis/Rrawpoppler) as an example.

`this` argument in C++ is similar to JS and `self` in Python

Note- the first thing to do is get RCIndex and RCodegen installed and
working!! Done.
