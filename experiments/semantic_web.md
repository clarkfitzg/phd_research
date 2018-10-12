Thu Oct 11 17:32:22 PDT 2018

Reading about JSON-LD and trying to understand it via the [playground](https://json-ld.org/playground/).


```
{
"@context": "http://www.w3.org/ns/csvw", 
"url": "data.csv",
"notes": [{"maxLength": 1e6}]
}
```
This expands fine. The context defines the terms `maxLength` and `url`.

Suppose I want to use keys from two contexts:
```
{
"@context": "http://www.w3.org/ns/csvw", 
"url": "data.csv",
"notes": [{"@context": "http://purl.org/dc/terms", "abstract": "cool beans"}]
}
```

