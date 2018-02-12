hist.png: chunk3.R data/l2.rds
	Rscript $<

data/iris/Sepal.Length.rds: chunk1.R
	Rscript $<

data/l2.rds: chunk2.R data/iris/Sepal.Length.rds
	Rscript $<
