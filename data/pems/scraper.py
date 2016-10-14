#!/usr/bin/env python

"""
Automates download from PeMS of a years worth of 30 second compressed raw
highway traffic sensor data, which is around 30 GB

Run this on poisson, save to scratch partition
"""

from lxml import etree
import requests


def pems_links(html_table_filename):
    """
    Build dictionary of links of (filename: link)
    """
    baseurl = "http://pems.dot.ca.gov"

    # After logging on to the website I just copied out the html table
    # containing the file links
    html = etree.parse(html_table_filename)

    filenodes = html.xpath("//a[@href]")
    links = {x.text: baseurl + x.xpath("@href")[0] for x in filenodes}

    return links


def download(links, cookies, datadir, chunk_size=10240):
    """
    Download links for binary files onto a local machine

    links:      dictionary of links
    cookies:    to send over with the request
    datadir:    directory to save the files when downloading

    Runs sequentially since parallel downloads are blocked
    """
    for fname, url in links.items():
        print("downloading {}... ".format(fname))
        r = requests.get(url, cookies=cookies, stream=True)
        with open(datadir + fname, "wb") as f:
            for chunk in r.iter_content(chunk_size):
                f.write(chunk)
        print("OK!\n")


if __name__ == "__main__":

    # Copy your cookie from the web browser and save it in this file
    with open("cookie.txt") as f:
        cookies = {"PHPSESSID": f.read().strip()}

    links = pems_links("dist3_raw30sec_13oct16.html")

    # Useful to test locally with just 2 before full download
    #links = dict((links.popitem(), links.popitem()))

    datadir = "/scratch/clarkf/pems/district3/"
    download(links, cookies, datadir=datadir)
