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


__kernel void  Fan1_kernel0(int lfpriv__Size, int lfpriv__t, __global float * a, __global float * m, int fan1_teams, int fan1_threads)
{
int _ti_100_501;
int lwpriv__i;
_ti_100_501=get_global_id(0);
#pragma acc  parallel loop num_workers(fan1_threads) gang worker present(a[0:(Size*Size)], m[0:(Size*Size)]) private(i) firstprivate(Size, t) num_gangs(fan1_teams)
if (_ti_100_501<(get_num_groups(0)*fan1_threads))
{
for (lwpriv__i=(_ti_100_501+0); lwpriv__i<((lfpriv__Size-1)-lfpriv__t); (lwpriv__i+=(get_num_groups(0)*fan1_threads)))
{
m[((lfpriv__Size*((lwpriv__i+lfpriv__t)+1))+lfpriv__t)]=(a[((lfpriv__Size*((lwpriv__i+lfpriv__t)+1))+lfpriv__t)]/a[((lfpriv__Size*lfpriv__t)+lfpriv__t)]);
}
}
}

__kernel void  Fan2_kernel0(int lfpriv__Size, int lfpriv__j, int lfpriv__t, __global float * a, __global float * b, __global float * m, int fan2_teams, int fan2_threads)
{
int _ti_100_501;
int lwpriv__i;
int lwpriv__j;
lwpriv__j=lfpriv__j;
_ti_100_501=get_global_id(0);
#pragma acc  parallel loop num_workers(fan2_threads) gang worker present(a[0:(Size*Size)], b[0:Size], m[0:(Size*Size)]) private(i) firstprivate(Size, j, t) num_gangs(fan2_teams)
if (_ti_100_501<(get_num_groups(0)*fan2_threads))
{
for (lwpriv__i=(_ti_100_501+0); lwpriv__i<((lfpriv__Size-1)-lfpriv__t); (lwpriv__i+=(get_num_groups(0)*fan2_threads)))
{
/* #pragma omp parallel for private(i) */
float m_0;
m_0=m[((lfpriv__Size*((lwpriv__i+1)+lfpriv__t))+lfpriv__t)];
for (lwpriv__j=0; lwpriv__j<(lfpriv__Size-lfpriv__t); lwpriv__j ++ )
{
a[((lfpriv__Size*((lwpriv__i+1)+lfpriv__t))+(lwpriv__j+lfpriv__t))]-=(m_0*a[((lfpriv__Size*lfpriv__t)+(lwpriv__j+lfpriv__t))]);
}
b[((lwpriv__i+1)+lfpriv__t)]-=(m_0*b[lfpriv__t]);
}
}
}

