
############################################################

slides.pdf : slides.tex
	pdflatex $<
	bibtex slides.aux
	pdflatex $<
	pdflatex $<
