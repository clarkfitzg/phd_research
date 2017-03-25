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

# 25.54 seconds
set.seed(1); system.time(smpl[, z := myfun(xb, a, b), by = id][])



require(Rcpp)   # v0.12.8

cppFunction(
'NumericVector myfun4(IntegerVector id, IntegerVector xb, NumericVector a, NumericVector b) {

  // ** id must be pre-grouped, such as via setkey(DT,id) **

  NumericVector z = NumericVector(id.length());
  int previd = id[0]-1;  // initialize to anything different than id[0]
  for (int i=0; i<id.length(); i++) {
    double prevb;
    if (id[i]!=previd) {
      // first row of new group
      z[i] = R::rnorm(a[i], 1);
      prevb = a[i]+z[i];
      previd = id[i];
    } else {
      // 2nd row of group onwards
      double at = prevb + xb[i];
      z[i] = R::rnorm(at, 1);
      prevb = at + z[i];
    }
  }
  return z;
}')

system.time(setkey(smpl,id))  # ensure grouped by id

# Wow, this is 0.28 seconds for me
set.seed(1); system.time(smpl[, z4 := myfun4(id, xb, a, b)][])

