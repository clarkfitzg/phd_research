# Split into files based on the first key
#awk -F, '{print >> "experiment_station/"$1}' threecolumns.csv

# Too many files- about 3500
# https://stackoverflow.com/questions/32878146/too-many-open-files-error-while-running-awk-command
awk -F, '{close("experiment_station/"$1)}{print >> "experiment_station/"$1}' threecolumns.csv

#'/pattern here/{close("file"i); i++}{print > "file"i}' InputFile

