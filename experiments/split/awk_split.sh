# TODO: Write a version that uses the sorted structure, and doesn't have to
# close every time.

# $ time ~/phd_research/experiments/split/split.sh
# real    0m48.964s
# user    0m11.876s
# sys     0m36.712s


# Split into files based on the first key
#awk -F, '{print >> "experiment_station/"$1}' threecolumns.csv

# Too many files- about 3500
# https://stackoverflow.com/questions/32878146/too-many-open-files-error-while-running-awk-command
awk -F, '{print >> "experiment_station/"$1; close("experiment_station/"$1)}' threecolumns.csv
#'/pattern here/{close("file"i); i++}{print > "file"i}' InputFile

