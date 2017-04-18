Mon Apr 17 15:58:27 PDT 2017

Amazingly, this approaches the theoretical limit for speeding things up,
going from about 13.5 to 7.5 seconds.

```
$ time make Y.txt
Rscript predict.R 1000 2000000 5 X.txt Y.txt

real    0m13.582s
user    0m10.568s
sys     0m3.224s


$ time make Y2.txt
Rscript step1.R 1000 2000000 5 X.txt Y2.txt &
Rscript step2.R 1000 2000000 5 X.txt Y2.txt

real    0m7.692s
user    0m4.640s
sys     0m3.092s


$ time make Y2.txt
Rscript step1.R 1000 2000000 5 X.txt Y2.txt &
Rscript step2.R 1000 2000000 5 X.txt Y2.txt

real    0m7.787s
user    0m4.800s
sys     0m3.012s
```

I believe the following error comes from sequencing. One tries to read
before the other is ready to write?

```
$ time make Y2.txt
Rscript step1.R 1000 2000000 5 X.txt Y2.txt &
Rscript step2.R 1000 2000000 5 X.txt Y2.txt
Error in socketConnection(port = 33000, open = "rb", timeout = 10, blocking
= TRUE) :
  cannot open the connection
In addition: Warning message:
In socketConnection(port = 33000, open = "rb", timeout = 10, blocking =
TRUE) :
  localhost:33000 cannot be opened
Execution halted
Makefile:9: recipe for target 'Y2.txt' failed
make: *** [Y2.txt] Error 1

real    0m0.160s
user    0m0.108s
sys     0m0.168s
clark@DSI-CF ~/phd_research/proposal/pipes (master)
$ Error in socketConnection(port = 33000, open = "wb", server = TRUE,
timeout = 10,  :
  cannot open the connection
In addition: Warning message:
In socketConnection(port = 33000, open = "wb", server = TRUE, timeout = 10,
:
  problem in listening on this socket
Execution halted
```
