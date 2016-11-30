# Wed Nov 30 10:01:37 PST 2016
# Print out package citations
#
# Rscript cite.R >> citations.bib

knitr::write_bib(c("RCIndex", "RCodeGen", "Rcpp"))
