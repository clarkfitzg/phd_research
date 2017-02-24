traffic.pdf: traffic.dot
	dot -Tpdf $< -o $@

traffic.dot: plot_traffic.R
	Rscript $<
