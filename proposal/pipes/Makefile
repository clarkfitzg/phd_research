CHUNKSIZE=1000
N:=$(shell wc -l X.txt | cut -f 1 -d " ")
NCOL:=$(shell head X.txt -n 1 | wc -w)

Y.txt: X.txt predict.R readargs.R
	time Rscript predict.R $(CHUNKSIZE) $(N) $(NCOL) $< $@

Y2.txt: X.txt step1.R step2.R
	Rscript step1.R $(CHUNKSIZE) $(N) $(NCOL) $< $@ &
	Rscript step2.R $(CHUNKSIZE) $(N) $(NCOL) $< $@
