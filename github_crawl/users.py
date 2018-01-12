import requests
from lxml import html


baseurl = "https://api.github.com"

# I don't think this one is searching on language, because I've never
# written Pascal
response = requests.get(baseurl + "/search/users",
        {"q": "clarkfitzg", "language": "Pascal"})

response = requests.get(baseurl + "/search/users",
        {"q": "clark+language:R"})


logins = [x["login"] for x in response.json()["items"]]
print(logins)
