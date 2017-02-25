"""
Download R gists from Github for inspection
"""

import requests
from lxml import html


baseurl = "https://api.github.com"

# This will get my gists, but it doesn't use the language filter
response = requests.get(baseurl + "/users/clarkfitzg/gists",
        {"language": "R"})

gists = [x["files"].popitem()[1] for x in response.json()]


# If I go on the website to search I can crawl these pages

res = requests.get("https://gist.github.com/search?l=R&q=data+analysis&utf8=%E2%9C%93")

fname = "gist_search.html"

with open(fname, "wb") as f:
    f.write(res.content)

page = html.parse(fname)

# Follow the file links, then follow the Raw links
