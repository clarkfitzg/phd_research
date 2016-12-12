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
covariance structure is block diagonal?

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
