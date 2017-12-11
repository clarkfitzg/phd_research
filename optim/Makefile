# Name of the report
REPORT = dag

IMG_NMS = program only_map
IMAGES = $(IMG_NMS:=.svg)

# Navigate web browser to localhost:8000
view: $(REPORT).html 
	python3 -m http.server 8000

# $< references the first prerequisite
$(REPORT).html : $(REPORT).md $(IMAGES)
	pandoc $< -s -o $@

clean:
	rm $(REPORT).html 

%.svg: %.dot
	dot -Tsvg $< -o $@
