
n_smpl = 1e6
ni = 5
id = rep(1:n_smpl, each = ni)

smpl = data.table(id)
smpl[, time := 1:.N, by = id]
a_init = 1; b_init = 1
smpl[, ':=' (a = a_init, b = b_init)]
smpl[, xb := (1:.N)*id, by = id]

myfun = function (xb, a, b) {

  z = NULL
  # initializes a new length-0 variable

  for (t in 1:length(xb)) {

      if (t >= 2) { a[t] = b[t-1] + xb[t] }
      # if() on every iteration. t==1 could be done before loop

      z[t] = rnorm(1, mean = a[t])
      # z vector is grown by 1 item, each time

      b[t] = a[t] + z[t]
      # assigns to all of b vector when only really b[t-1] is
      # needed on the next iteration 
  }
  return(z)
}

# 25.54 seconds
set.seed(1); system.time(smpl[, z := myfun(xb, a, b), by = id][])
