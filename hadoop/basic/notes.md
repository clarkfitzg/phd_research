This 'weekday mapper' script is extremely interesting.
https://cwiki.apache.org/confluence/display/Hive/GettingStarted
It maps an arbitrary Python script onto the data. Curious that it uses
stdin / stdout to transfer the data via text. This means that both hive and
Python have to specify the datatypes / parse the strings. It would seem
better to pass the correct datatype over in Python. Maybe that is what
Spark offers. But R could do this reasonably well for a group by / apply
operation.

Tue Oct 17 10:18:31 PDT 2017

When I try again here to run something similar with R I see:

```
Caused by: java.io.IOException: Cannot run program "Rscript": error=2, No
such file or directory
```
 
This may mean that the `Rscript` command is not available on the worker
nodes? Indeed, that was the same error as the original one, had I dug
through it more carefully!

Yes, this was the error.


