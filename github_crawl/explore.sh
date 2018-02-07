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

# Which ones use parallel?
find $dd -path "*.R" -type f -print0 | \
    xargs -0 grep "library\([\"']?parallel" -oP | \
    cut  -d "/" -f 7 | \
    sort -n | \
    uniq | \
    cat


# How often are the apply families used?
find $dd -path "*.R" -type f | \
    xargs grep "\K([sltv]apply|Map|Reduce|mclapply)" -oP | \
    sort | \
    uniq -c | \
    sort -n | \
    #wc -l | \
    cat
