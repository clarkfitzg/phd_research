import json
import time
import os
import subprocess

import requests



def download(url = None, page = 1, search = "data analysis", license = "mit", language = "R"):
    # Can only have five logical operators

    query = " ".join((search,
        "NOT assignment",
        "NOT workshop",
        "NOT tutorial",
        "NOT coursera",
        "NOT course",
        "language:{} license:{}".format(language, license),
        "fork:false mirror:false"))

    if url is None:
        r = requests.get("https://api.github.com" + "/search/repositories",
                {"q": query, "per_page": 100, "page": page})
    else:
        r = requests.get(url)

    return {"links": r.links,
            "repos": r.json()["items"],
            }


if __name__ == "__main__":

    r = download()
    lasturl = r["links"]["last"]["url"]
    repos = r["repos"]

    while(True):
        time.sleep(1)
        try:
            r = download(r["links"]["next"]["url"])
            repos += r["repos"]
        except KeyError:
            break

    starting_dir = os.getcwd()
    data_dir = os.path.expanduser("~/data/code/r_data_analysis/")
    os.chdir(data_dir)

    with open("meta.json", "w") as f:
        json.dump(repos, f)

    for url in (r["git_url"] for r in repos):
        time.sleep(1)
        subprocess.run(["git", "clone", url])

    os.chdir(starting_dir)

# 
# r = download()
# 
# r1 = r[1]
# 
# licenses = ("mit", "gpl")
# r["total_count"]
# 
# len(r["items"])
# 
# [x["name"] for x in r["items"]]
# 
# [x["description"] for x in r["items"]]
# 
# nd2 = [x["name"] for x in r["items"]]
# 
# print(nd)
