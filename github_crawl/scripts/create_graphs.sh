# TODO: Myfanwy's gst_rheo_Experiments don't yet work
for file in *.R; do
    Rscript ~/phd_research/codedepends/codegraph.R $file
done

pdfunite *.pdf 
