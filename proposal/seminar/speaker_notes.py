splitter = """

============================================================

"""

with open("slides.tex") as f:
    for line in f:
        line = line.rstrip()
        if line.startswith("%C"):
            comment = line.replace("%C", "")
            if not comment:
                print(splitter)
            else:
                print(comment)
