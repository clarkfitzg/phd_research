# Tue Feb  6 13:38:06 PST 2018
# Some basic exploration of the github repos

dd="/home/clark/data/code/r_data_analysis"

# 2437 R files
find $dd -path "*.R" -type f | wc -l

# Which libraries are being used?
# 843 calls, 201 different libraries.
# And not a single call to 
find $dd -path "*.R" -type f | \
    xargs grep "library\(\K(\S+)\)" --no-filename -oP 2> /dev/null | \
    tr -d \'\"')' | \
    sort | \
    uniq -c | \
    sort -n | \
    #wc -l | \
    grep "ggplot" | \
    cat


# How often are the apply families used?
find $dd -path "*.R" -type f | \
    xargs grep "\K([sltv]apply|Map|Reduce|mclapply)" -oP | \
    sort | \
    uniq -c | \
    sort -n | \
    #wc -l | \
    cat
