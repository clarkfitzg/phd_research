# Name of the report
REPORT = dag

# Navigate web browser to localhost:8000
view: $(REPORT).html 
	python3 -m http.server 8000

# $< references the first prerequisite
$(REPORT).html : $(REPORT).md program.svg
	pandoc $< -s -o $@

clean:
	rm $(REPORT).html 

program.svg: program.dot
	dot -Tsvg $< -o $@
