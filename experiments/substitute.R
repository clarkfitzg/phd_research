# https://cran.r-project.org/doc/manuals/r-release/R-lang.html#Substitutions
# http://adv-r.had.co.nz/Computing-on-the-language.html#substitute
# Currently this doesn't allow injecting actual expressions in, i.e. blocks of code.
# I could hack around this using c() on expressions, or with braces, but I think I'll take the rstatic route instead.
substitute_language1 = function(expr, env)
{
    if(is(expr, "expression")){
        out = lapply(expr, substitute_language1, env)
        as.expression(out)
    } else {
        call <- substitute(substitute(y, env), list(y = expr))
        eval(call)
    }
}


as.expression.Brace = function(x)
{
    statements = lapply(x$contents, rstatic::as_language)
    as.expression(statements)
}


as.expression.ASTNode = function(x)
{
    as.expression(rstatic::as_language(x))
}


substitute_language2 = function(expr, env, ast = rstatic::to_ast(expr))
{
    replacer = function(node){
        if(is(node, "Symbol") && node$value %in% names(env)){
            rstatic::to_ast(env[[node$value]])
        } else {
            node
        }
    }
    rstatic::replace_nodes(ast, replacer, in_place = TRUE)
    as.expression(ast)
}


# TODO: Is there a better way to do this?
# look at dput, substitute
convert_object_to_language = function(x)
{
    parse(text = deparse(x))[[1L]]
}


if(FALSE){

    # Minimal example of what the code substition should support.
    # BLOCK is an arbitrary block of code.
    template = parse(text = "
        VARNAME = VALUE
        foo(VARNAME)
        BLOCK
    ")

    v = as.symbol("x")
    l = list(1:2, 3:4)
    b = parse(text = "
              bar(1)
              1 + 2
              ")

    # Works, puts a brace { in, which isn't a big deal.
    substitute_language2(template, list(VARNAME = v,
        VALUE = convert_object_to_language(l),
        BLOCK = b
        ))

    # Doesn't work with the BLOCK, gives nested expressions
    substitute_language1(template, list(VARNAME = v,
        VALUE = l,
        BLOCK = b
        ))

    # Doesn't work because rstatic doesn't convert a list to an AST.
    # rstatic's behavior here is reasonable.
    substitute_language2(template, list(VARNAME = v,
        VALUE = l,
        BLOCK = b
        ))

}
