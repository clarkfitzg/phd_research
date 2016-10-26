# Wed Oct 26 09:07:37 PDT 2016
#
# Process a 5 minute file into a form suitable for visualization in D3

datadir = "/home/clark/data/pems/"


columns_from_html = function(htmlfile){
    # Read the column names and metadata from a saved html file

    tree = XML::htmlParse(htmlfile)
    rows = XML::getNodeSet(tree, '//div[@id="Help_station_5min"]//tr')

    # These positions may be different
    readrow = function(row) XML::getChildrenStrings(row)[c(1, 3)]
    # Some newlines seem to be missing, but oh well.

    cleanrows = lapply(rows, readrow)
    out = data.frame(do.call(rbind, cleanrows[-1]))
    colnames(out) = cleanrows[[1]]
    out
}


infer_colnames = function(htmlfile = "5min.html", nlanes = 8){

    columns = columns_from_html(htmlfile)
    original = as.character(columns[["Name"]])
    original = gsub("%", "Percent", original)

    pattern = "Lane N"
    haslanes = grep(pattern, original)
    lanes = columns[["Name"]][haslanes]

    replaceN = function(N) gsub(pattern, paste("Lane", N), lanes)
    withN = lapply(seq(nlanes), replaceN)

    withN = c(list(original[- haslanes]), withN)
    out = unlist(withN)
    gsub(" ", "", out)
}


columns = infer_colnames()


if(FALSE){

fivemin = read.csv(paste0(datadir, "d03_text_station_5min_2016_10_25.txt")
                   , header=FALSE
                   , col.names = columns
                   )

}


