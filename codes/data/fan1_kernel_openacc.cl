__kernel void  Fan1_kernel0(__global float * a, __global float * m, int Size, int fan1_gangs, int fan1_workers, int t)
{
int _ti_100_501;
int lwpriv__i;
_ti_100_501=get_global_id(0);
#pragma acc  kernels loop gang(fan1_gangs) worker(fan1_workers) independent copyin(Size, t) present(a[0:(Size*Size)], m[0:(Size*Size)]) private(i)
if (_ti_100_501<(get_num_groups(0)*fan1_workers))
{
for (lwpriv__i=(_ti_100_501+0); lwpriv__i<((Size-1)-t); (lwpriv__i+=(get_num_groups(0)*fan1_workers)))
{
m[((Size*((lwpriv__i+t)+1))+t)]=(a[((Size*((lwpriv__i+t)+1))+t)]/a[((Size*t)+t)]);
}
}
}
