
############################################################

all: slides.pdf speaker_notes.txt


slides.pdf : slides.tex
	pdflatex $<
	pdflatex $<

speaker_notes.txt: speaker_notes.py
	python $< > $@
