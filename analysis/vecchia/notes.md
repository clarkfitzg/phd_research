Thu Dec 15 15:57:57 PST 2016

Duncan asked me to step back and try to abstract the ideas here.

seeing a balance between improved statistical estimation and
run time.


Mon Dec 12 10:43:46 PST 2016

Reading Joseph Guiness' paper "Permutation Methods for Sharpening
Gaussian Process Approximations" https://arxiv.org/pdf/1609.05372.pdf
to understand computation for Vecchia's approximate likelihood.

stochastic advection-diffusion partial differential equations (SPDEs)
used for weather prediction
[paper](https://www.researchgate.net/profile/Hans_Kuensch/publication/224861441_SPDE_based_modeling_of_large_space-time_data_sets/links/53e87e9a0cf21cc29fdc63e3.pdf).

Let's start with part 3, assume that the permutations have happened.

Section 3.2 talks about grouping the data to share calculation of
conditional density. This looks like some of what Ethan and I talked about on the
board.

Still not totally clear what the groups are. If they're a partition of the
data, as stated in sec 3.2 then it seems like the assumption is that the
covariance structure is block diagonal? But that's not the case because
he mentions that case in section 5. Better make some kind of picture here.

> when working with small covariance matrices, the computational demand is
> often dominated by filling in the entries of the covariance matrix rather
> than factoring the matrix.

I remember Ethan telling me this.

> Searching for nearest neighbors in metric spaces is a well-studied
> problem.

k-d trees used for this.

Interesting how he does approximate simulations of n dimensional Gaussian
with known covariance matrix in O(n) operations. A matrix - vector multiply
takes O(n^2). I never considered the need to do an approximate simulation.
Done in this case to quantify uncertainty.

Matèrn covariance function used to simulate. The special case of
exponential covariance is also used.

Results compared through KL divergence- smaller is better.
- using more neighbors is better
- Grouped is better than ungrouped
- Choice of neighbors (permutations) matters

What exactly is sorting the coordinates? Does this mean that he's using
neighbors based on the coordinates? No, just looked at figure 1. So
maximizing minimum distance MMD always picks the corners.

Types of groups:
1. MMD
2. Random uniform
3. middle out
4. Sorted on one coordinate

So what about a neighborhood of points in the metric space sense?

For each particular group we can evaluate the likelihood. But how to get
from this to the full likelihood approximation? If it's just multiplication
then it seems like it's equivalent to a permuted block structure in the
covariance matrix. But what about Vecchia's itself? Suppose you only
consider the previous 10 observations. Is this something like an AR(10)
time series model?

Run time is on the order of 1 minute for exponential covariance.

In the data example in Figure 7 they all seem pretty close to the same
value. Also this seems to have gracefully handled the missing data? Not
totally clear what these predictions / interpolations are, and what the
point is. I guess knowing the covariance is nice for being able to
simulate.

This seems like the same problem, broken down into chunks and then solved
again? Are we using the full conditional form for each block?

Seems like there might be other ways to do this based on some special form
of Matérn covariance matrices. Do the matrices themselves define some way
to split up the computations?
