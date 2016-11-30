# Name of the report
# Required
TEXFILE = report

all: $(TEXFILE).pdf

# $< references the first prerequisite
$(TEXFILE).pdf: $(TEXFILE).tex citations.bib
	pdflatex $<
	bibtex $(TEXFILE).aux
	pdflatex $<
	pdflatex $<

rcite: cite.R
	Rscript $< >> citations.bib

view:
	open $(TEXFILE).pdf

clean :
	rm {*.aux,*.bbl,*.blg,*.log,*.out}
