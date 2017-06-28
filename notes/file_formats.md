Wed Jun 28 08:34:27 PDT 2017

Duncan asked me yesterday to prepare a 20 minute talk on file formats in
data science, what they are, how they work, what use cases they solve. The
summary here mostly comes from Wikipedia.

Data science primarily uses data in a "write-once, read-many" pattern.
We load the data, or a subset of the data, and perform analysis. Unlike a
transactional database it's uncommon to update or delete individual records
in place.


| Format    | Year Began    | Characteristics
|-----------|---------------|----------------
| CSV       | Dawn of time  | tabular, plain text, row oriented
| XML       | 1996          | hierarchical, plain text, supports schema and validation
| JSON      | early 2000's  | hierarchical, plain text, simple
| HDF5      | early 1990's  | array oriented, binary, sophisticated, includes software
| Parquet   | 2013          | column oriented, Hadoop


# Data Formats

### CSV

CSV stands for "comma separated values" or "comma separated, variable
length".  This is the "lowest common denominator" since most every program
that processes tabular data can deal with CSV. I'm lumping all delimited
text files in with this.  Fixed width format is similar, since it's plain
text with one row per line.

The problem with CSV is that there are so many different conventions for
things such as delimiters, row numbering, and escaping quotes. A robust
program needs to be capable of handling all the different options.

RFC 4180 documents a standard for CSV.


### XML

Extensible Markup Language (XML) is a flexible, general purpose
hierarchical data storage format. Use cases include exchanging data on the
internet and storing word processing documents. Schemas allow specifying
types and certain relationships among elements. Tools such as `xpath` can
efficiently query XML documents, ie. find elements of interest without
reading the entire document into memory.


### JSON

Javascript Object Notation (JSON) supports two containers: key value pairs
and arrays. Like XML it's commonly used for data exchange on the internet.

Primitive objects include
- Numbers (doubles)
- Strings
- Boolean
- null

JSON translates simply and unambiguously into programming languages that have these
two containers, which is probably why many prefer it over XML.


### HDF5

Hierarchical Data Format (HDF5) was originally designed to store and
process large amounts of scientific data. It has a rich data model and
includes a mature software implementation written in C. It stores data in a
binary form and scales up to compute clusters.

netCDF uses HDF5. 

### Parquet

Parquet represents 
Based on the storage format described in Google's 2010 Dremel paper.


# Storage Mechanisms

### Cloud storage

For typical data science applications it can make sense to pay a
service to physically store large amounts of data. As of June 2017, Amazon
S3 costs around $20 / month to store 1 terabyte of data in standard
storage, and $4 / month in "Glacier Storage".  I have a few rows stored at
https://clarks-test-bucket.s3.amazonaws.com/tiny.txt


