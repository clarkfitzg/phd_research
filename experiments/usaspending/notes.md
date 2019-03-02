(poisson)-usaspending$ time psql -f transaction.sql > transaction.csv

real    29m55.141s
user    0m43.119s
sys     1m30.941s


To write the 70 GB CSV file it takes about 1 hour:
Without filtering:
```
(poisson)-usaspending$ time psql -f transaction.sql > transaction.csv

real    55m11.209s
user    0m58.316s
sys     1m58.515s
```

Change users to access the DB: 

```

sudo -u usaspending -i

```

materializing the views took just over 24 hours.

The query to join the agency tables, 71 million or so, takes about 1 minute.
Then saving it to a 7.3 GB csv file is pretty fast, i.e. just limited by disc IO.
In contrast, It takes 1-2 hours 

Result should have this many rows:
71604797

CSV file has this many lines:
71611788

Which means that there are newlines in the data.

