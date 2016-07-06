# Create the CSV file locally
Rscript orange.csv

# Copy to HDFS
hadoop fs -cp file::///orange.csv hdfs://
