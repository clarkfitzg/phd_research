closure = function(){
    function(x) x
}

c1 = closure()

c1(y <- 20)


# Does sending a closure to a remote worker actually send the environment?

one_GB = runif(2^30 / 8)

environment(c1)$one_GB = one_GB

cls = parallel::makeCluster(2, "PSOCK")

# This takes quite a while. So yes, the data is sent. Then I look in my
# task manager and see this huge processes.
parallel::clusterExport(cls, "c1")
