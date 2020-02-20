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
