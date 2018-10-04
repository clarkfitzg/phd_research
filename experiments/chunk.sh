# Randomly split big.txt into 5 equal size chunks named
# big.txtaa, big.txtab, etc.
shuf big.txt | split -n r/5 - big.txt
