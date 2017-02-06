__kernel void add1(__global const float *x
        , __global float *out
        , const int n
        )
{
    int id = get_global_id(0);
}
