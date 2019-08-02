# I'm wondering how fast we can split and rearrange data so that it's ready for a GROUP BY.
# I'm trying to do it in the shell here.

DATAFILE=data.csv

DATAFILE=(~/data/pems/d04_text_station_raw_2016_08_22.txt.gz)

# From https://unix.stackexchange.com/questions/114061/extract-data-from-a-file-and-place-in-different-files-based-on-one-column-value

time gunzip -stdout $DATAFILE | awk -F, '{ print > ($2 ".csv") }' 
