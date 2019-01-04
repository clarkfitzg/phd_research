function jfunc(x)
    return exp.(x) .+ 1
end

v = [0., 1, 2]

jfunc(v)
