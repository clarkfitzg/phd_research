"""
Tools for working with PeMS data in Python
"""

import itertools
import pandas as pd
import requests
from lxml import etree


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


def read_station_raw(fname):
    """
    Read a single raw (30 second) station data file into a Pandas
    data.frame. These tend to be huge.
    """
    p = itertools.product(range(8), "flow occupancy mph".split())
    repeated = [x[1] + str(x[0] + 1) for x in p]
    oneday = pd.read_csv(fname,
            header=None,
            names=["timestamp", "ID"] + repeated,
            )
    return oneday
