Mon Apr 17 15:58:27 PDT 2017

Amazingly, this approaches the theoretical limit for speeding things up.

```
$ time make
time Rscript predict.R 1000 2000000 5 X.txt Y.txt
10.96user 3.50system 0:14.31elapsed 101%CPU (0avgtext+0avgdata
33604maxresident)k
0inputs+38904outputs (0major+8051minor)pagefaults 0swaps

real    0m14.347s
user    0m10.972s
sys     0m3.520s
clark@DSI-CF ~/phd_research/proposal/pipes (master)
$ rm Y2.txt
clark@DSI-CF ~/phd_research/proposal/pipes (master)
$ time make Y2.txt
Rscript step1.R 1000 2000000 5 X.txt Y2.txt &
Rscript step2.R 1000 2000000 5 X.txt Y2.txt

real    0m7.792s
user    0m4.800s
sys     0m2.992s
clark@DSI-CF ~/phd_research/proposal/pipes (master)
$
```
