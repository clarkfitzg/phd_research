#!/usr/bin/env python

"""
Automates download from PeMS of a years worth of 30 second compressed raw
highway traffic sensor data, which is around 30 GB

Run this on poisson, save to scratch partition
"""

import pems


if __name__ == "__main__":

    # TODO: clean this up and have the script take all these as command
    # line args

    # Copy your cookie from the web browser and save it in this file
    with open("cookie.txt") as f:
        cookies = {"PHPSESSID": f.read().strip()}

    links = pems.pems_links("dist4_raw30sec_13oct16.html")

    # Useful to test locally with just 2 before full download
    #links = dict((links.popitem(), links.popitem()))

    datadir = "/scratch/clarkf/pems/district4/"
    pems.download(links, cookies, datadir=datadir)
