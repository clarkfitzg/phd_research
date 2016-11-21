# Name of the report
# Required
TEXFILE = report

# TODO: change for server
DATADIR = /home/clark/data/pems

all: $(TEXFILE).pdf

# $< references the first prerequisite
$(TEXFILE).pdf: $(TEXFILE).tex citations.bib
	pdflatex $<
	bibtex $(TEXFILE).aux
	pdflatex $<
	pdflatex $<

view:
	xdg-open $(TEXFILE).pdf

clean :
	rm {*.aux,*.bbl,*.blg,*.log,*.out}

dirs: setup5min.R
	Rscript $< $(DATADIR)

totals: totals.R
	Rscript $< $(DATADIR)

scrape: dist4_5min_17nov16.html chp_incidents.html
	./scraper.py --cookie cookie.txt --linkhtml chp_incidents.html --datadir /scratch/clarkf/pems/chp
	./scraper.py --cookie cookie.txt --linkhtml $< --datadir /scratch/clarkf/pems/5min_district4

test_scrape: dist4_5min_17nov16.html
	./scraper.py --cookie cookie.txt --linkhtml $< --test

testchp: chp_incidents.html
	./scraper.py --cookie cookie.txt --linkhtml $< --test
