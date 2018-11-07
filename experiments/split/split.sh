# Split into files based on the first key
awk -F, '{print >> "station/"$1}' sorted_data.txt
