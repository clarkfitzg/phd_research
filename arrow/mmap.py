"""
Fri Jul 14 11:36:58 PDT 2017

Goal:
Share a memory mapped file between two Python processes

Following
https://arrow.apache.org/docs/python/memory.html#on-disk-and-memory-mapped-files
"""

import pyarrow as pa


# For a more realistic use case this would be a Parquet file
fname = '../example.dat'
with open(fname, 'wb') as f:
    f.write(b'some example data')


mmap = pa.memory_map(fname, 'r')

mmap.read()
mmap.seek(0)

# Modify the actual file
with open(fname, 'wb') as f:
    f.write(b'SOME EXAMPLE DATA')

# Now we see the modified contents, even from a different process.
mmap.read()
