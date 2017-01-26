Mon Jan 23 10:11:55 PST 2017

If we fix n to be approximately 10 million and vary the number of summands
in each term the best we can do is having 6 summands per thread- function
evaluations take 3.4 ms. In comparison, pure (optimized) Julia using
floating point math takes 140 ms, a speedup of 40x.

Wondering if it's worth it to try to use `float4` vector data types in
OpenCL to use SIMD instructions. This would not be good for code
readability, because these have no meaning in this context. 

There's code in this directory to show
`CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE = 1` for the GPU on Pearson.
According to this [Stack
Overflow](http://stackoverflow.com/a/23421180/2681019) this is the way of
modern GPU architectures. So we don't have to worry about `float4` types
and SIMD here. At least at this level.

I see no other obvious ways to accelerate this.

Intuitively, adding another reduce kernel should only make this slower. It
would be good to verify this.

Mon Jan 23 16:01:41 PST 2017

I added a separate reduce kernel so that tps is computed for each
term and stored in an intermediate array. Then the sum reduces that array
into an array of partial sums. Surprisingly this is faster than the above
at 3.0 ms, which brings the speedup to 46x.
