This 'weekday mapper' script is extremely interesting.
https://cwiki.apache.org/confluence/display/Hive/GettingStarted
It maps an arbitrary Python script onto the data. Curious that it uses
stdin / stdout to transfer the data via text. This means that both hive and
Python have to specify the datatypes / parse the strings. It would seem
better to pass the correct datatype over in Python. Maybe that is what
Spark offers. But R could do this reasonably well for a group by / apply
operation.

This experiment was surprisingly successful. The next step is to run it on
the whole data and time it. First I need to probably unzip these .gz files.

