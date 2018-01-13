import requests
from lxml import html


baseurl = "https://api.github.com"

# This finds me
response = requests.get(baseurl + "/search/users",
        {"q": "clark language:R"})

print(response.url)

logins = [x["login"] for x in response.json()["items"]]
print(logins)
