# Name of the report
# Required
TEXFILE = summer17

all: $(TEXFILE).pdf
# $< references the first prerequisite
$(TEXFILE).pdf: $(TEXFILE).tex
	pdflatex $<
	bibtex $(TEXFILE).aux
	pdflatex $<
	pdflatex $<

view:
	open $(TEXFILE).pdf

clean :
	rm {*.aux,*.bbl,*.blg,*.log,*.out}
