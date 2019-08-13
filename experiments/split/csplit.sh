# Trying to write a basic regex to match something that has a different first character in the next line.
# I don't think this will work, because regex work one line at a time.

# Nothing
grep "1,(.|\n)*2" sorted_data.txt

grep "1,.*\n2" sorted_data.txt

