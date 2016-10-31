Thu Oct 27 16:27:31 PDT 2016

When invoking `.Call()` one may pass in the return value and modify it, or
one may use `PROTECT, allocVector, UNPROTECT` in the C code. Is one of these
preferred? When do we have to use one or the other?
