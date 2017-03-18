all: ast.pdf codegraph.pdf

codegraph.pdf: codegraph.dot
	dot -Tpdf $< -o $@

ast.pdf: ast.R
	R -f $<
	#Rscript $< --verbose
