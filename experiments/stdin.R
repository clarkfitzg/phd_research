stream_in = file("stdin")
open(stream_in)

queue = data.table::fread(stream_in, nrows = 2)

print(queue)
