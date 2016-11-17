all: dist4_5min_17nov16.html chp_incidents.html
	./scraper.py --cookie cookie.txt --linkhtml chp_incidents.html --datadir /scratch/clarkf/pems/chp
	./scraper.py --cookie cookie.txt --linkhtml $< --datadir /scratch/clarkf/pems/district4/5min

test: dist4_5min_17nov16.html
	./scraper.py --cookie cookie.txt --linkhtml $< --test

testchp: chp_incidents.html
	./scraper.py --cookie cookie.txt --linkhtml $< --test
