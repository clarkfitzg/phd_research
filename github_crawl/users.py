import requests
from lxml import html


baseurl = "https://api.github.com"

response = requests.get(baseurl + "/search/users",
        {"q": "clark", "language": "R"})

logins = [x["login"] for x in response.json()["items"]]
