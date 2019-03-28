library(CodeDepends)


f = function(){
    x = f()                     # 1
    if( foo ) x = g()           # 2
    h(x)                        # 3
}

info = getInputs(f)

# Why doesn't this work?
# lapply(info, `@`, "code")

dt = getDetailedTimelines(info = info)

getDependsThread("x", info)
