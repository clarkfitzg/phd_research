library(BenfordTests)


# Using data downloaded from
# http://www.fec.gov/finance/disclosure/ftpdet.shtml
# Individual contributions file for 2017 is 4GB

r = edist.benftest(x)

header = as.character(read.table("indiv_header_file.csv", sep = ","
                    , stringsAsFactors = FALSE))

keepers = c("CMTE_ID", "ENTITY_TP", "TRANSACTION_AMT")
keep = header %in% keepers

cc = rep("NULL", length(header))
cc[keep] = c("factor", "factor", "numeric")


itcont = read.table("~/data/itcont.txt"
           , sep = "|"
           , colClasses = cc
           , skip = 300
           )
colnames(itcont) = keepers



itcont = read.table("~/data/itcont.txt"
           , sep = "|"
           , nrows = 500
           )

colnames(itcont) = keepers
