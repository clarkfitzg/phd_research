# Name of the report
# Required
TEXFILE = relational_algebra

all: $(TEXFILE).pdf

# $< references the first prerequisite
$(TEXFILE).pdf: $(TEXFILE).tex ../citations.bib
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
