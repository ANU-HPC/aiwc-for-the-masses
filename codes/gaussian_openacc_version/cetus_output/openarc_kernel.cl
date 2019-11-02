#ifndef __OpenCL_KERNELHEADER__ 
#define __OpenCL_KERNELHEADER__ 
/**********************************************/
/* Added codes for OpenACC2OpenCL translation */
/**********************************************/
#ifdef __cplusplus
#define restrict __restrict__
#endif
#define MAX(a,b) (((a) > (b)) ? (a) : (b))
#define MIN(a,b) (((a) < (b)) ? (a) : (b))
#ifndef FLT_MAX
#define FLT_MAX 3.402823466e+38
#endif
#ifndef FLT_MIN
#define FLT_MIN 1.175494351e-38
#endif
#pragma OPENCL EXTENSION cl_khr_fp64: enable
#ifndef DBL_MAX
#define DBL_MAX 1.7976931348623158e+308
#endif
#ifndef DBL_MIN
#define DBL_MIN 2.2250738585072014e-308
#endif
#endif


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

__kernel void  Fan2_kernel0(__global float * a, __global float * b, __global float * m, int Size, int fan2_gangs, int fan2_workers, int t)
{
int _ti_100_501;
int lwpriv__i;
int lwpriv__j;
_ti_100_501=get_global_id(0);
#pragma acc  kernels loop gang(fan2_gangs) worker(fan2_workers) independent copyin(Size, t) present(a[0:(Size*Size)], b[0:Size], m[0:(Size*Size)]) private(i, j)
if (_ti_100_501<(get_num_groups(0)*fan2_workers))
{
for (lwpriv__i=(_ti_100_501+0); lwpriv__i<((Size-1)-t); (lwpriv__i+=(get_num_groups(0)*fan2_workers)))
{
float m_0;
m_0=m[((Size*((lwpriv__i+1)+t))+t)];
#pragma acc  loop private(j)
for (lwpriv__j=0; lwpriv__j<(Size-t); lwpriv__j ++ )
{
a[((Size*((lwpriv__i+1)+t))+(lwpriv__j+t))]-=(m_0*a[((Size*t)+(lwpriv__j+t))]);
}
b[((lwpriv__i+1)+t)]-=(m_0*b[t]);
}
}
}

