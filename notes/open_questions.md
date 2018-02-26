Fri Dec 16 13:30:02 PST 2016

Came across some very nice material on R and C++ by Chris Paciorek
http://www.stat.berkeley.edu/scf/paciorek-cppWorkshop.pdf.
He works on NIMBLE, might be good to look more into that.

Thu Oct 27 16:27:31 PDT 2016

When invoking `.Call()` one may pass in the return value and modify it, or
one may use `PROTECT, allocVector, UNPROTECT` in the C code. Is one of these
preferred? When do we have to use one or the other?
