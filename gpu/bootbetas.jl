using BenchmarkTools
using OpenCL

b0 = 1
b1 = 5
sigma = 10
n = Int32(10_000)
nboots = Int32(1_000)

srand(37)
x = Float32.(rand(n))

epsilon = Float32.(sigma * randn(n))

y = b0 + b1 * x + epsilon

device, ctx, queue = cl.create_compute_context()

# Copy over to the device
xd = cl.Buffer(Float32, ctx, (:r, :copy), hostbuf = x)
yd = cl.Buffer(Float32, ctx, (:r, :copy), hostbuf = y)

# Column major array storing bootstrapped b0, b1
beta_d = cl.Buffer(Float32, ctx, :w, 2*nboots)

const kernel_src = open("bootbeta.cl") do f
   readstring(f)
end
program = cl.Program(ctx, source = kernel_src) |> cl.build!

kernel = cl.Kernel(program, "bootbeta")

"""
Signature to match:

__kernel void bootbeta(__global const float *x
        , __global const float *y
        , __global float *betas
		, int n
        )
"""

function runboot(nboots)
    queue(kernel, nboots, nothing
        , xd
        , yd
        , beta_d
        , n
        )
    return cl.read(queue, beta_d)
end

b = runboot(nboots)

# Runs in about 9.2 ms. And they're all unique and look to be in the right
# ballpark. That means it seems to have worked!
@benchmark runboot(nboots)
