# From https://github.com/duncantl/CodeDepends/issues/19

library(CodeDepends)

code = "f2 = function(a, b) {
    rnorm(a) * b
}
f = function(x, y, z) {
        f2(y, x) + x
}
"
scr = readScript(txt = code)
inp = getInputs(scr)

## now do a second pass for f
findFuncDef = function(fname, scrinfo ) {
        ind = which(sapply(scrinfo, function(x) fname %in% c(x@outputs, x@updates)))
   if(length(ind) == 0)
               stop("no function of that name found")
      else if (length(ind) > 1)
                  ind = max(ind)
          scrinfo[[ind]]
}

f_el = findFuncDef("f", inp)

## remember the functions slot has a unintuitive/weird on the face of it format
## names(x@functions) is the function names, while x@functions is a logical indicating
## whether the function was defined "locally" ie in the script (TRUE) or not (e.g. package functions) (FALSE)
##
## this is why!
funcsval = f_el@functions
calledlocal = names(funcsval[!is.na(funcsval) & funcsval])

allinputs = f_el@inputs
allfuncs = f_el@functions

for(fi in calledlocal) {
        fi_el = findFuncDef(fi, inp)
   allinputs = c(allinputs, fi_el@inputs)
       allfuncs = c(allfuncs, fi_el@functions)
}

## clean up duplicates, in this case `{`
allfuncs = allfuncs[!duplicated(paste(allfuncs, names(allfuncs)))]

print(allinputs)
character(0)

print(allfuncs)
