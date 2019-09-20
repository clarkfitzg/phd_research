---
geometry: margin=2cm
header-includes:
    - \usepackage{setspace}
    - \doublespacing

---

## 2019 Summer Research Award - UC Davis Statistics Dept

9/19/2019
    
Richard Clark Fitzgerald, PhD Candidate

This summer I have focused on writing and revising my PhD dissertation.
I completed a full draft of my dissertation that I will submit to my committee shortly.
I plan to graduate in Winter 2019 and begin as an Assistant Professor at Sacramento State University in January.
I have been at the UC Davis campus for the entire summer, from June through September.
I have not had any summer employment.
Professor Duncan Temple Lang can endorse my research activities.

My research is focused on making R code faster by automatically making it parallel, which means the programs use many processors simultaneously.
Besides writing my dissertation, I had two significant steps forward this summer.
The first step was improving the static code analysis my software relies on.
This improvement paved the way for the second step, a more practical and general approach to data parallel programs.

The static code analysis infers which subexpressions in an R script correspond to large objects.
It begins with a symbol for a known large data object, and a set of functions which produce large data objects when the input is a large data object because they operate elementwise.
The analysis then recursively descends into the end user's code, and records which subexpressions must also be large data objects.
I built everything on Nick Ulle's excellent `rstatic` R package for static analysis, and provided Nick with feedback and use cases along the way.

The new approach for data parallel programs is more practical because it avoids data movement.
The idea is to read the data in chunks, and perform as many operations on each as possible, which keeps those chunks local on each worker.
I used code fully generated with this approach to speed up a practical data analysis problem by a factor of three.
