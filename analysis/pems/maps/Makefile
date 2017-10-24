serve: station.json
	python3 -m http.server 8000

station.json: station_json.R ../station_cluster.csv
	Rscript $<

link:
	cp -f ~/phd_research/analysis/pems/maps/* ~/public_html/fd
