"""
Scraping vets appeals data.

Mon Aug  7 09:08:20 PDT 2017
Checking the results, this script currently only downloads 67813 files.
This corresponds to the default selection of years 2016 - 2017.
It's enough to work with though.
"""

from lxml import etree
import requests


def download(RS = "1", datadir = "/home/clark/data/vets/appeals/"):
    """
    Download and save 50 of the VA appeals using links provided by the
    search engine.
    """
    baseurl = "https://www.index.va.gov/search/va/bva_search.jsp"
    response = requests.get(baseurl, params = {"RPP": "50", "RS": RS})
    html = etree.HTML(response.text)
    links = html.xpath('//*[@id="results-area"]/div/a/@href')

    for link in links:
        response = requests.get(link)
        fname = datadir + link.split("/")[-1]
        with open(fname, "w") as f:
            f.write(response.text)


def main():
    """
    Attempt to download everything.
    """
    total_results = 961333
    for RS in range(1, total_results, 50):
        RS = str(RS)
        download(RS)
        print("downloaded {}".format(RS))


if __name__ == "__main__":
    main()
