library(CodeDepends)

fname = "simple2.R"

s = readScript(fname)

# Can I cat this right back into a file now?

# It's just a list
selectSuperClasses("Script")

# Of language objects
typeof(s[[1]])

# Maybe just hijack the print method?
print(s[[1]])

sink(paste0("mod_", fname))
for(expression in s){
    print(expression)
}
sink()
