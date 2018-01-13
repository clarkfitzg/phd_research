import requests

import json

baseurl = "https://api.github.com"


def download(search = "data analysis", license = "mit", language = "R"):
    # Can only have five logical operators

    query = " ".join((search,
        "NOT assignment",
        "NOT package",
        "NOT workshop",
        "NOT tutorial",
        "NOT coursera",
        "language:{} license:{}".format(language, license),
        "fork:false mirror:false"))

    response = requests.get(baseurl + "/search/repositories",
            {"q": query, "per_page": 100, "page": page})

    

page = 1

licenses = ("mit", "gpl")
r["total_count"]

r["items"][99]["forks"]

l = response.headers["Link"]
len(r["items"])

[x["name"] for x in r["items"]]

[x["description"] for x in r["items"]]

nd2 = [x["name"] for x in r["items"]]

print(nd)
