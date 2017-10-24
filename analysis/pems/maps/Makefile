serve: station.json
	python3 -m http.server 8000

station.json: station_json.R ../station_cluster.csv
	Rscript $<

link:
	ln -s ~/phd_research/analysis/pems/maps/web/* ~/public_html/cluster
