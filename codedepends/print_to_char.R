# Capture printed output through a temporary file.
# Hopefully there's a better way to do this!
print_to_char = function(x, nchars = 10000L)
{
    f = tempfile()
    on.exit(unlink(f))
    sink(f)
    print(x)
    sink()
    out = readChar(f, nchars)
    # Drop the trailing newline
    gsub("\n$", "", out)
}
