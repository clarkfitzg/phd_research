Fri Oct 27 13:13:32 PDT 2017

Doesn't seem like I can do large simultaneous queries. Makes
sense...

Starting out there are 54 errors from the '\N'.

```

yarn logs -applicationId application_1480440170646_0166 -log_files stderr > err1.txt

yarn logs -applicationId application_1480440170646_0172 -log_files stderr | less

BEGIN R SCRIPT
Entering main stream processing loop.
Processing group 401516
Error in scan(file = file, what = what, sep = sep, quote = quote, dec =
dec,  :
  scan() expected 'an integer', got '\N'
Calls: read.table -> scan
Execution halted
org.apache.hadoop.hive.ql.metadata.HiveException: [Error 20002]: Hive
encountered some unknown error while running your custom script.
 
grep "Error in scan" err1.txt  | wc

     #54     972    4374
```

I can probably deal with this by transforming as follows:
https://stackoverflow.com/questions/43556160/null-data-converted-into-n-for-numeric-columns-in-hive

Possibly an easier way is to call `read.table(na.strings = "\\N")` in the R
script.

```

alter table mytable set tblproperties('serialization.null.format'='')
;

```

But why didn't all of them fail? We see 

```
$ grep "END R SCRIPT" err1.txt | wc
     39     117     507
```

Fri Oct 27 15:50:38 PDT 2017

Working my way through various errors. Now I see this:

```
        ... 14 more
  scan() expected 'a logical', got '1'
Calls: read.table -> scan
Execution halted
```

There is also a ton of unnecessary stuff mixed in with the error logs,
which I need to remove.

