# Name of the report
# Required
TEXFILE = fitzgerald_QE

all: $(TEXFILE).pdf

layers.pdf: layers.dot
	dot -Tpdf $< -o $@

workflow.pdf: workflow.dot
	dot -Tpdf $< -o $@

pipeline.pdf: pipeline.dot
	dot -Tpdf $< -o $@

snow.pdf: snow.dot
	dot -Tpdf $< -o $@

iterator.pdf: iterator.dot
	dot -Tpdf $< -o $@

codegraph.pdf: codegraph.dot
	dot -Tpdf $< -o $@

# $< references the first prerequisite
$(TEXFILE).pdf: $(TEXFILE).tex ../citations.bib workflow.pdf codegraph.pdf
	pdflatex $<
	bibtex $(TEXFILE).aux
	pdflatex $<
	pdflatex $<

view:
	open $(TEXFILE).pdf

clean :
	rm {*.aux,*.bbl,*.blg,*.log,*.out}
