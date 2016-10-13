# Run this on poisson, save to scratch partition
from lxml import etree
import requests


baseurl = "http://pems.dot.ca.gov"

# Controls streaming download
chunk_size = 10240

# After logging on to the website I just copied out the html table
# containing the file links
html = etree.parse("raw30sec_d4_13oct16.html")

# Copy your cookie from the web browser and save it in this file
with open("cookie.txt") as f:
    cookies = {"PHPSESSID": f.read().strip()}

# Where to save the files when downloading
#datadir = "/scratch/pems/"
datadir = "/home/clark/data/pems/"

# Build dictionary of links of (filename: link)
filenodes = html.xpath("//a[@href]")
links = {x.text: baseurl + x.xpath("@href")[0] for x in filenodes}

# Useful to test locally with 2 before full download
links = dict((links.popitem(), links.popitem()))


def scrape(links, cookies, datadir, chunk_size=10240):
    """
    MUST run sequentially since parallel downloads are blocked
    """
    for fname, url in links.items():
        print("downloading {}... ".format(fname))
        r = requests.get(url, cookies=cookies, stream=True)
        with open(datadir + fname, "wb") as f:
            for chunk in r.iter_content(chunk_size):
                f.write(chunk)
        print("OK!\n")
