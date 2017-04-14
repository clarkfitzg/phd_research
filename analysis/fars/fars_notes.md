This data is on traffic fatalities. 

## Download

Use [ftplib](https://docs.python.org/3/library/ftplib.html) which is part of the standard library.

## Unzip

Here we're using Python much like we would use the command line. The
main advantage is a much cleaner syntax than bash.

## Open DBF files

```
clark@DSI-CF ~/data/fars/1986
$ ls
acc1986.dbf  per1986.dbf  veh1986.dbf
clark@DSI-CF ~/data/fars/1986
$ file acc1986.dbf
acc1986.dbf: FoxBase+/dBase III DBF, 41090 records * 558, update-date 08-11-6, at offset 1537 1st record "      1.0000     89.0000      1.0000      2.0000     86.0000   "
```

The data is saved in `FoxBase+/dBase III DBF` format.  We start looking
into it and realize that everything is encoded using numeric values. Yuck.
To make life easy I'll work with codes that are easiest to understand, like
time.
