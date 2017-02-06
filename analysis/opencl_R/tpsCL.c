#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <unistd.h>


#ifdef __linux__
    #include <CL/opencl.h>
#elif __APPLE__
    #include <OpenCL/opencl.h> 
#endif

#define MAX_SOURCE_SIZE (0x100000)

float rand_uniform()
{
        return rand() / (RAND_MAX + 1.);
}


double time_spent(clock_t begin, clock_t end)
{
    return (double)(end - begin) / CLOCKS_PER_SEC;
}


int main( int argc, char* argv[] )
{
    // Dimension of vectors
    // TODO: When I use 1e2, 1e3, 1e4 I get segfaults. Why?
    int n = (int) 1e7;
    int k = 10;
    int nk = n * k;

    // Arbitrary element to evaluate
    float x = 3.14159;

    // Host input vectors
    float *h_coef;
    float *h_controlpts;
    // Host output vector
    float *h_out;

    // Size, in bytes, of each vector
    size_t bytes = nk*sizeof(float);
    size_t outbytes = n*sizeof(float);

    // Allocate memory for each vector on host
    h_coef = (float*)malloc(bytes);
    h_controlpts = (float*)malloc(bytes);
    h_out = (float*)malloc(outbytes);

    // Initialize vectors on host
    int i;
    for( i = 0; i < nk; i++ )
    {
        h_coef[i] = rand_uniform();
        h_controlpts[i] = rand_uniform();
    }

    // Adding this to test for correctness on the first row
    for( i = 0; i < k; i++ )
    {
        h_coef[i] = 1.0;
        h_controlpts[i] = (float) i;
    }


    //------------------------------------------------------------
    // OpenCL starts here

    /* Load kernel source file */
    // From
    // https://www.fixstars.com/en/opencl/book/OpenCLProgrammingBook/calling-the-kernel/
    FILE *fp;
    const char fileName[] = "./tps_kernel.cl";
    size_t source_size;
    char *kernelSource;

    fp = fopen(fileName, "r");
    if (!fp) {
        fprintf(stderr, "Failed to load kernel.\n");
        exit(1);
    }
    kernelSource = (char *)malloc(MAX_SOURCE_SIZE);
    source_size = fread(kernelSource, 1, MAX_SOURCE_SIZE, fp);
    fclose(fp);

    // Device input buffers
    cl_mem d_coef;
    cl_mem d_controlpts;
    // Device output buffer
    cl_mem d_out;

    cl_platform_id cpPlatform;        // OpenCL platform
    cl_device_id device_id;           // device ID
    cl_context context;               // context
    cl_command_queue queue;           // command queue
    cl_program program;               // program
    cl_kernel kernel;                 // kernel

    size_t globalSize, localSize;
    cl_int err;

    // Number of work items in each local work group
    // TODO: What does this do? This may be a bug, go look!
    // Thi
    localSize = 100;

    // Number of total work items - localSize must be devisor
    globalSize = ceil(n/(float)localSize)*localSize;

    // Bind to platform
    err = clGetPlatformIDs(1, &cpPlatform, NULL);

    // Get ID for the device
    err = clGetDeviceIDs(cpPlatform, CL_DEVICE_TYPE_GPU, 1, &device_id, NULL);

    // Create a context
    context = clCreateContext(0, 1, &device_id, NULL, NULL, &err);

    // Create a command queue
    queue = clCreateCommandQueue(context, device_id, 0, &err);

    // Create the compute program from the source buffer
    program = clCreateProgramWithSource(context, 1,
                            (const char **) & kernelSource, NULL, &err);

    // Build the program executable
    clBuildProgram(program, 0, NULL, NULL, NULL, NULL);

    // Create the compute kernel in the program we wish to run
    kernel = clCreateKernel(program, "thin_plate_spline", &err);

    // Create the input and output arrays in device memory for our calculation
    d_coef = clCreateBuffer(context, CL_MEM_READ_ONLY, bytes, NULL, NULL);
    d_controlpts = clCreateBuffer(context, CL_MEM_READ_ONLY, bytes, NULL, NULL);
    d_out = clCreateBuffer(context, CL_MEM_WRITE_ONLY, outbytes, NULL, NULL);

	clock_t t0 = clock();

    // Write our data set into the input array in device memory
    err = clEnqueueWriteBuffer(queue, d_coef, CL_TRUE, 0,
                                   bytes, h_coef, 0, NULL, NULL);
    err |= clEnqueueWriteBuffer(queue, d_controlpts, CL_TRUE, 0,
                                   bytes, h_controlpts, 0, NULL, NULL);

    // Set the arguments to our compute kernel
    err  = clSetKernelArg(kernel, 0, sizeof(float), &x);
    err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &d_coef);
    err |= clSetKernelArg(kernel, 2, sizeof(cl_mem), &d_controlpts);
    err |= clSetKernelArg(kernel, 3, sizeof(cl_mem), &d_out);
    err |= clSetKernelArg(kernel, 4, sizeof(int), &k);
    err |= clSetKernelArg(kernel, 5, sizeof(int), &n);

	clock_t t1 = clock();
    // Execute the kernel over the entire range of the data set
    err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &globalSize, &localSize,
                                                              0, NULL, NULL);

    // Wait for the command queue to get serviced before reading back results
    clFinish(queue);
	clock_t t2 = clock();

    // Read the results from the device
    clEnqueueReadBuffer(queue, d_out, CL_TRUE, 0,
                                outbytes, h_out, 0, NULL, NULL );
	clock_t t3 = clock();

    printf("Dimensions: n = %i, k = %i\n", n, k);
    printf("\n");
    printf("Transfer input to device (GPU): %f sec\n", time_spent(t0, t1));
    printf("Run compute kernel:             %f sec\n", time_spent(t1, t2));
    printf("Return output to host (CPU):    %f sec\n", time_spent(t2, t3));
    printf("Total:                          %f sec\n", time_spent(t0, t3));
    printf("\n");
    printf("Correct?\n");
    printf("Expected: 143.6215\n");
    printf("Actual: %f\n", h_out[0]);

    // release OpenCL resources
    clReleaseMemObject(d_coef);
    clReleaseMemObject(d_controlpts);
    clReleaseMemObject(d_out);
    clReleaseProgram(program);
    clReleaseKernel(kernel);
    clReleaseCommandQueue(queue);
    clReleaseContext(context);

    //release host memory
    free(h_coef);
    free(h_controlpts);
    //*** glibc detected *** ./tpsCL: free(): invalid pointer: 0x00007fc58431f010 ***
    // Why?
    free(h_out);
    free(kernelSource);

    return 0;
}
