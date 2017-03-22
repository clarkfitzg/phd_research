# Name of the report
# Required
TEXFILE = fitzgerald_QE

all: $(TEXFILE).pdf

# $< references the first prerequisite
$(TEXFILE).pdf: $(TEXFILE).tex ../citations.bib
	pdflatex $<
	bibtex $(TEXFILE).aux
	pdflatex $<
	pdflatex $<

view:
	open $(TEXFILE).pdf

clean :
	rm {*.aux,*.bbl,*.blg,*.log,*.out}
