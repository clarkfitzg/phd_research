import numpy as np
import pandas as pd
from numba import jit


n_smpl = int(1e6)
ni = 5
group_id = np.repeat(np.arange(n_smpl), ni)
a = np.repeat(1, len(group_id))
b = np.repeat(1, len(group_id))
time = 1 + np.tile(np.arange(ni), n_smpl)
xb = group_id * time


@jit(nopython=True)
def myfun(group_id=group_id, xb=xb, a=a, b=b):
    """
    This version iterates over the Numpy arrays
    """
    z = np.empty(len(xb))
    cur_id = group_id[0]
    cur_a = a[0]
    cur_b = b[0]
    for t in range(len(xb)):
        # Relying on sorted group ids, like itertools.groupby
        # This marks the start of a new group:
        if group_id[t] != cur_id:
            cur_id = group_id[t] 
            cur_a = a[t]
            cur_b = a[t]
        else:
            cur_a = cur_b + xb[t]

        z[t] = cur_a + np.random.randn(1)[0]
        cur_b = cur_a + z[t]

    return z

# Don't want to include the compilation time, so run one here
z0 = myfun()


# Sweet, this runs in 0.63 seconds
if __name__ == "__main__":
    from time import time
    t0 = time()
    z = myfun()
    diff = time() - t0
    print("Took {} seconds. Here's head and tail of z:\n".format(diff))
    print(z[:10])
    print(z[-10:])
