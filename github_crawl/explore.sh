# Tue Feb  6 13:38:06 PST 2018
# Some basic exploration of the github repos

dd="/home/clark/data/code/r_data_analysis"

# 2437 R files
find $dd -path "*.R" -type f | wc -l

# Which libraries are being used?
# 565 different libraries.
find $dd -path "*.R" -type f -print0 | \
    xargs -0 grep "library\(\K(\S+)\)" -oP --no-filename | \
    tr -d \'\"')' | \
    sort | \
    uniq -c | \
    sort -n | \
    #wc -l | \
    #grep "parallel" | \
    cat


# Which ones use specific packages?
find $dd -path "*.R" -type f -print0 | \
    xargs -0 grep "library\([\"']?RPostgreSQL" -oP | \
    cut  -d "/" -f 7 | \
    sort | \
    uniq | \
    cat

# RPostgreSQL
############################################################
# cona
# NHL_regression
# nyc-citibike-data

# RMySQL
############################################################
# BRC_Keloid
# BRC_SingleCell_LJames
# DataAnalytics
# HPRU_RSV
# myTCGA
# pullreqs-contributors
# Schisto_medip

# parallel
############################################################
# BRC_SingleCell_LJames
# DBDA2Eprograms
# DBDA2E-utilities
# gpseq-seq-gg
# MetaAnalysisJaegerEngelmannVasishth2017
# seq-lib-gg

apply="\K([sltv]apply|Map|Reduce|mclapply)" 

# How often are the apply families used? fairly common.
find $dd -path "*.R" -type f -print0 | \
    xargs -0 grep $apply -oP --no-filename | \
    sort | \
    uniq -c | \
    sort -n | \
    cat


# Which repos use them?
# 152 out of 301. Half of them.
find $dd -path "*.R" -type f -print0 | \
    xargs -0 grep $apply -oP | \
    cut  -d "/" -f 7 | \
    sort | \
    uniq | \
    wc -l | \
    cat


# Which repos use Reduce?
# 9 out of 301.
find $dd -path "*.R" -type f -print0 | \
    xargs -0 grep "Reduce\(" -oP | \
    cut  -d "/" -f 7 | \
    sort | \
    uniq | \
    wc -l | \
    cat
