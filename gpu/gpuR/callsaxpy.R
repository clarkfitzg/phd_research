library(gpuR)


detectGPUs()

detectCPUs()

cl_args <- setup_opencl(objects = c("vclVector", "vclVector", "scalar")
	, intents = c("IN", "OUT", "IN")
	, queues = list("SAXPY", "SAXPY", "SAXPY")
	, kernel_maps = c("x", "y", "a")
)

# Actually compiles the kernel
custom_opencl("saxpy.cl", cl_args, "float")

a <- 2
x <- rnorm(16)
y <- rnorm(16)

expected = a*x + y

gpuA <- vclVector(x, type = "float")
gpuB <- vclVector(y, type = "float")

saxpy(gpuA, gpuB, a)

# output returned through 2nd arg
actual = gpuB[]

diff = expected - actual

# O(1e-7) single precision accuracy, as expected
max(abs(diff))
