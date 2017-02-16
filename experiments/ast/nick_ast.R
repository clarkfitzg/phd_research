# Thu Feb 16 13:17:30 PST 2017
#
# Using Nick's ast package
# https://github.com/nick-ulle/ast

library(ast)

ab_code = parse("ab.R")

# hacks to convert expression into a language object
ab2 = append(list("{"), as.list(ab_code))
ab3 = do.call(call, ab2, quote = TRUE)

q = quote({
    a <- 10
    b <- a + 5
    plot(a)
    fit <- lm(a ~ b)
    if(TRUE) print("hey")
})

#abtree = ast::to_ast(ab_code)
ab_ast = to_ast(ab3)

ab_ig = as_igraph(ab_ast)

ab_cfg = to_cfg(ab_ast)
