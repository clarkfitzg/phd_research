// https://en.wikipedia.org/wiki/Linear_congruential_generator
// Using glibc version
int next_rand(int x)
{
    // (ax + c) % m
    return (1103515245 * x + 12345) % 2147483647;
}


// n is the length of x, y
__kernel void bootbeta(__global const float *x
        , __global const float *y
        , __global float *betas
		, int n
        )
{

    int id = get_global_id(0);

    // Seed using the id
    int random_state = next_rand(id);

    int iboot;
    float sumx = 0.0;
    float sumy = 0.0;
    float sumx2 = 0.0;
    float sumxy = 0.0;

    for(int i = 0; i < n; i++)
    {
        random_state = next_rand(random_state);
        iboot = random_state % n;

        sumx += x[iboot];
        sumy += y[iboot];
        sumx2 += x[iboot] * x[iboot];
        sumxy += x[iboot] * y[iboot];
    }
    float nd = (float) n;
    float xbar = sumx / nd;
    float ybar = sumy / nd;
    float x2bar = sumx2 / nd;
    float xybar = sumxy / nd;

    float b1 = (xybar - xbar * ybar) / (x2bar - xbar * xbar);
    float b0 = ybar - b1 * xbar;

    betas[2 * id] = b0;
    betas[2 * id + 1] = b1;
}
