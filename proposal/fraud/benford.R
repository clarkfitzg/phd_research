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
           , nrows = 300
           )
#colnames(itcont) = keepers

# line 270 doesn't have 21 elements

itcont = read.table("~/data/itcont.txt"
           , sep = "|"
           , colClasses = cc
           , skip = 100
           , nrows = 300
           )
# skip = 10, fails on line 260, consistent with above
# skip = 50, fails on line 220, consistent with above
# skip = 100, works fine 


itcont = data.table::fread("~/data/itcont.txt", sep = "|", nrows = 500)


lines = readLines("~/data/itcont.txt", n = 500)

ls = strsplit(lines, "|", fixed =TRUE)

unique(sapply(ls, length))

ls[[270]]


# This works. Inexplicably.
itcont = read.table("~/data/bad3.txt"
           , sep = "|"
           , nrows = 300
           )

colnames(itcont) = keepers
