Mon Oct  9 16:36:03 PDT 2017

Talking with Ozan and Brian Love, corn silage breeder for Land of Lakes.
As a breeder, his job is to look at data as it comes in and decide whether
or not to continue breeding a certain variety. If it seems promising, they
pollinate and go another year. If it performs poorly, they stop.

Covariates include:

- yield in tons (important)
- moisture content
- starch content
- height
- number of plants which grew (variable, depends on people counting)
- ... many more

An idea is to use this data to train a neural network to make the decision
to continue breeding. This is interesting to Brian because he can go back
and look at what the machine picked, but he didn't. I'd like to compare
what a neural network does with something more conventional like logistic
regression.

The other interesting feature of this data set is that the data becomes
complete over time, and one has to make decisions before it is complete.
For example, samples are sent in to the lab for analysis.
