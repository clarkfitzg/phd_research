CHUNKSIZE=10
N:=$(shell wc -l X.txt | cut -f 1 -d " ")
NCOL:=$(shell head X.txt -n 1 | wc -w)
TIMEOUT=1

Y.txt: X.txt predict.R readargs.R
	Rscript predict.R $(CHUNKSIZE) $(N) $(NCOL) $< $@

Y2.txt: X.txt step1.R step2.R readargs.R
	Rscript step1.R $(CHUNKSIZE) $(N) $(NCOL) $< $@ $(TIMEOUT) &
	Rscript step2.R $(CHUNKSIZE) $(N) $(NCOL) $< $@ $(TIMEOUT) 

Y3.txt: X.txt step1A.R step2A.R step3A.R readargs.R
	Rscript step1A.R $(CHUNKSIZE) $(N) $(NCOL) $< $@ $(TIMEOUT) &
	Rscript step2A.R $(CHUNKSIZE) $(N) $(NCOL) $< $@ $(TIMEOUT) &
	Rscript step3A.R $(CHUNKSIZE) $(N) $(NCOL) $< $@ $(TIMEOUT) 
