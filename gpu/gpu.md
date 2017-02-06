Mon Feb  6 08:34:17 PST 2017

I've had fun writing these OpenCL kernels. It would be nice if this was
simpler to do in R. But I don't yet have any real use cases for doing this,
aside from the Vecchia example. Just the same, lets review a little of
what's available.

Determan's [gpuR
package](https://www.r-bloggers.com/r-gpu-programming-for-all-with-gpur/)
seems to be getting it right, using OpenCL. The goal is to keep things high
level and reduce boilerplate.

Seems to do most operations with doubles? How does this work when not all
GPU's support that?

It claims that
[ViennaCL](http://viennacl.sourceforge.net/viennacl-about.html) provides
auto tuned kernels in the backend. 

Matloff's [2015 article on
GPU's](https://www.r-bloggers.com/parallel-programming-with-gpus-and-r/)
explains that threads run in blocks- each of which does exactly the same
thing in parallel. So using an `if` statement can cause __Thread
divergence__, where one is working and the others are idle.

Besard et. al. [High-level GPU programming in
Julia](https://arxiv.org/pdf/1604.03410.pdf) describes compiling Julia for
the GPU. Ie. writing the kernel function in Julia. This is really what all
the languages should be doing.
