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


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) Fan1_kernel0(int lfpriv__Size, int lfpriv__t, __global float * a, __global float * m)
{
int lwpriv__i;
lwpriv__i=get_global_id(0);
#pragma acc  parallel loop num_workers(64) gang worker independent present(a[0:(Size*Size)], m[0:(Size*Size)]) private(i) firstprivate(Size, t) num_gangs(((int)ceil((((float)((-1+Size)+(-1*t)))/64.0F))))
if (lwpriv__i<((lfpriv__Size-1)-lfpriv__t))
{
m[((lfpriv__Size*((lwpriv__i+lfpriv__t)+1))+lfpriv__t)]=(a[((lfpriv__Size*((lwpriv__i+lfpriv__t)+1))+lfpriv__t)]/a[((lfpriv__Size*lfpriv__t)+lfpriv__t)]);
}
return ;
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) Fan2_kernel0(int lfpriv__Size, int lfpriv__t, __global float * a, __global float * m)
{
int lgpriv__i;
int _ti_100_201;
lgpriv__i=get_group_id(0);
#pragma acc  parallel loop num_workers(64) gang independent present(a[0:(Size*Size)], m[0:(Size*Size)]) private(i, j) firstprivate(Size, t) num_gangs(((-1+Size)+(-1*t)))
if (lgpriv__i<((lfpriv__Size-1)-lfpriv__t))
{
_ti_100_201=get_local_id(0);
#pragma acc  loop worker independent private(j)
{
int lwpriv__j;
for (lwpriv__j=(_ti_100_201+0); lwpriv__j<(lfpriv__Size-lfpriv__t); (lwpriv__j+=64))
{
a[((lfpriv__Size*((lgpriv__i+1)+lfpriv__t))+(lwpriv__j+lfpriv__t))]-=(m[((lfpriv__Size*((lgpriv__i+1)+lfpriv__t))+lfpriv__t)]*a[((lfpriv__Size*lfpriv__t)+(lwpriv__j+lfpriv__t))]);
}
}
}
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) Fan2_kernel1(int lfpriv__Size, int lfpriv__t, __global float * b, __global float * m)
{
int lwpriv__i;
lwpriv__i=get_global_id(0);
#pragma acc  parallel loop num_workers(64) gang worker independent present(b[0:Size], m[0:(Size*Size)]) private(i) firstprivate(Size, t) num_gangs(((int)ceil((((float)((-1+Size)+(-1*t)))/64.0F))))
if (lwpriv__i<((lfpriv__Size-1)-lfpriv__t))
{
b[((lwpriv__i+1)+lfpriv__t)]-=(m[((lfpriv__Size*((lwpriv__i+1)+lfpriv__t))+lfpriv__t)]*b[lfpriv__t]);
}
}

