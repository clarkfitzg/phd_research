"""
http://stackoverflow.com/questions/41886507/data-table-faster-row-wise-recursive-update-within-group/41891693#41891693

require(data.table)   # v1.10.0
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

Clark: Just following the naive version here to get some idea of the
speedup
"""

import numpy as np
import pandas as pd


n_smpl = int(1e6)
ni = 5

group_id = np.repeat(np.arange(n_smpl), ni)

smpl = pd.DataFrame({"id": group_id})

a_init = 1; b_init = 1

#smpl[, time := 1:.N, by = group_id]
smpl["time"] = 1 + np.tile(np.arange(ni), n_smpl)

#smpl[, ':=' (a = a_init, b = b_init)]
smpl["a"] = a_init
smpl["b"] = b_init
smpl["xb"] = smpl["id"] * smpl["time"]

def myfun(chunk):
    xb = chunk["xb"].values
    a = chunk["a"].values
    b = chunk["b"].values
    z = np.empty(len(chunk))

    #for (t in 1:length(xb)) {
    for t in range(len(xb)):

        # if() on every iteration. t==1 could be done before loop
        if (t >= 1):
            a[t] = b[t-1] + xb[t]

        z[t] = a[t] + np.random.randn(1)

        b[t] = a[t] + z[t]
        # assigns to all of b vector when only really b[t-1] is
        # needed on the next iteration 

    return pd.DataFrame(z)


# Little test for correctness
smpl2 = smpl[:20].copy()
smpl2["z"] = smpl2.groupby("id").apply(myfun).values
smpl2


# The actual one- takes 5min 44s!!
if __name__ == "__main__":
    from time import time
    t0 = time()
    smpl["z"] = smpl.groupby("id").apply(myfun).values
    diff = time() - t0
    print("Took {} seconds.".format(diff))
