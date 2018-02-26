Thu Feb  2 08:48:18 PST 2017

Some ideas from Duncan:

Mechanism in registration to check if users call .C rather than .Call.
Could potentially be R patch.

`RCIndex` can be used to generate and or verify arg signatures for C
routines.

Any kind of code analysis tools can go in the `CodeAnalysis` package.
Better to keep them together. The idea is to put all the higher level
functionality stuff outside of the `CodeDepends`.
