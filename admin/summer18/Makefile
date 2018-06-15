# Name of the report
REPORT = fitzgerald_proposal_summer18

# $< references the first prerequisite
$(REPORT).pdf : $(REPORT).md
	pandoc -s $< -o $@ -V geometry:margin=1in -V fontsize=12pt

view :
	open $(REPORT).pdf
