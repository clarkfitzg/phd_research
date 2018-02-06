# Tue Feb  6 13:38:06 PST 2018
# Some basic exploration of the github repos

dd="/home/clark/data/code/r_data_analysis"

# 2437 R files
find $dd -path "*.R" -type f | wc -l

# Which libraries are being used?
find $dd -path "*.R" -type f | xargs grep "library(" --only-matching --no-filename
