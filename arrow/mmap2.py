import pyarrow as pa

fname = 'example.dat'

mmap = pa.memory_map(fname)

mmap.read()

mmap.seek(0)

mmap.read()
