COLUMN=description
COLNUM=16   # The numeric value of COLUMN. It would be better to infer this from data.
WORD=education
INFILE=/home/clarkf/data/transaction_normalized.csv
OUTFILE=/home/clarkf/data/${COLUMN}-${WORD}.txt

head ${INFILE} \
    | cut -d , -f 16 \
    | Rscript stream_find_word.R ${WORD} \
    > ${OUTFILE}
