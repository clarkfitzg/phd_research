CHUNKSIZE=1000
N:=$(shell wc -l X.csv | cut -f 1 -d " ")

Y.csv: X.csv node1.R node2.R
	Rscript node1.R $(CHUNKSIZE) $(N)
	Rscript node2.R
