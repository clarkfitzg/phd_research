roxygen2::roxygenize(".")
install.packages(".", repos = NULL)
devtools::test()
