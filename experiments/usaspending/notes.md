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

