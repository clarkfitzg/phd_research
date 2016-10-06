#!/usr/bin/python3

"""
Thu Oct  6 11:00:18 PDT 2016
Inspecting fullConfig.xml as generated from Matsim.

How many parameters does it have?
"""

from lxml import etree


def main():
    with open("fullConfig.xml") as f:
        tree = etree.parse(f)


    names = ("module", "param", "parameterset")
    nodes = (tree.xpath("//" + nm) for nm in names)
    counts = {nm: len(nd) for nm, nd in zip(names, nodes)}

    print(counts)


if __name__ == "__main__":

    main()
