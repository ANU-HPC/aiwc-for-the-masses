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


struct Node
{
int starting;
int no_of_edges;
};

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) BFSGraph_kernel0(int lfpriv__no_of_nodes, __global _Bool * h_graph_mask, __global _Bool * h_graph_visited, __global _Bool * h_updating_graph_mask)
{
int lwpriv__i;
lwpriv__i=get_global_id(0);
#pragma acc  parallel loop num_workers(64) gang worker independent present(h_graph_mask[0:no_of_nodes], h_graph_visited[0:no_of_nodes], h_updating_graph_mask[0:no_of_nodes]) private(i) firstprivate(no_of_nodes) num_gangs(((int)ceil((((float)no_of_nodes)/64.0F))))
if (lwpriv__i<lfpriv__no_of_nodes)
{
h_updating_graph_mask[lwpriv__i]=0;
h_graph_mask[lwpriv__i]=0;
h_graph_visited[lwpriv__i]=0;
}
}

__kernel void __attribute__((reqd_work_group_size(1, 1, 1))) BFSGraph_kernel1(__global _Bool * h_graph_mask, __global _Bool * h_graph_visited, int source)
{
/* set the source node as true in the mask */
h_graph_mask[source]=1;
h_graph_visited[source]=1;
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) BFSGraph_kernel2(int lfpriv__no_of_nodes, int lfpriv__source, __global int * h_cost)
{
int lwpriv__i;
lwpriv__i=get_global_id(0);
#pragma acc  parallel loop num_workers(64) gang worker independent present(h_cost[0:no_of_nodes]) private(i) firstprivate(no_of_nodes, source) num_gangs(((int)ceil((((float)no_of_nodes)/64.0F))))
if (lwpriv__i<lfpriv__no_of_nodes)
{
h_cost[lwpriv__i]=( - 1);
if (lwpriv__i==lfpriv__source)
{
h_cost[lfpriv__source]=0;
}
}
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) BFSGraph_kernel3(int lfpriv__id, int lfpriv__no_of_nodes, __global int * h_cost, __global int * h_graph_edges, __global _Bool * h_graph_mask, __global struct Node * h_graph_nodes, __global _Bool * h_graph_visited, __global _Bool * h_updating_graph_mask)
{
int lwpriv__tid;
int lwpriv__i;
int lwpriv__id;
lwpriv__id=lfpriv__id;
lwpriv__tid=get_global_id(0);
#pragma acc  parallel loop num_workers(64) gang worker independent present(h_cost[0:no_of_nodes], h_graph_edges[0:edge_list_size], h_graph_mask[0:no_of_nodes], h_graph_nodes[0:no_of_nodes], h_graph_visited[0:no_of_nodes], h_updating_graph_mask[0:no_of_nodes]) private(i, tid) firstprivate(id, no_of_nodes) num_gangs(((int)ceil((((float)no_of_nodes)/64.0F))))
if (lwpriv__tid<lfpriv__no_of_nodes)
{
if (h_graph_mask[lwpriv__tid]==1)
{
h_graph_mask[lwpriv__tid]=0;
for (lwpriv__i=h_graph_nodes[lwpriv__tid].starting; lwpriv__i<(h_graph_nodes[lwpriv__tid].no_of_edges+h_graph_nodes[lwpriv__tid].starting); lwpriv__i ++ )
{
lwpriv__id=h_graph_edges[lwpriv__i];
if ( ! h_graph_visited[lwpriv__id])
{
h_cost[lwpriv__id]=(h_cost[lwpriv__tid]+1);
h_updating_graph_mask[lwpriv__id]=1;
}
}
}
}
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) BFSGraph_kernel4(__global _Bool * restrict lgred__stop, int lfpriv__no_of_nodes, __global _Bool * h_graph_mask, __global _Bool * h_graph_visited, __global _Bool * h_updating_graph_mask)
{
int lwpriv__tid;
int _bid;
int _bsize;
int _tid;
__local volatile _Bool lwreds__stop[64];
int _ti_100_1001;
int _ti_100_1002;
int _ti_100_1003;
_tid=((get_local_id(0)+(get_local_id(1)*get_local_size(0)))+(get_local_id(2)*(get_local_size(0)*get_local_size(1))));
_bsize=((get_local_size(0)*get_local_size(1))*get_local_size(2));
_bid=((get_group_id(0)+(get_group_id(1)*get_num_groups(0)))+(get_group_id(2)*(get_num_groups(0)*get_num_groups(1))));
lwreds__stop[_tid]=0;
lwpriv__tid=get_global_id(0);
#pragma acc  parallel loop num_workers(64) gang worker vector reduction(||: stop) present(h_graph_mask[0:no_of_nodes], h_graph_visited[0:no_of_nodes], h_updating_graph_mask[0:no_of_nodes]) private(tid) firstprivate(no_of_nodes) num_gangs(((int)ceil((((float)no_of_nodes)/64.0F))))
if (lwpriv__tid<lfpriv__no_of_nodes)
{
if (h_updating_graph_mask[lwpriv__tid]==1)
{
h_graph_mask[lwpriv__tid]=1;
h_graph_visited[lwpriv__tid]=1;
lwreds__stop[_tid]=1;
h_updating_graph_mask[lwpriv__tid]=0;
}
}
barrier(CLK_LOCAL_MEM_FENCE);
_ti_100_1002=_bsize;
for (_ti_100_1001=(_bsize>>1); _ti_100_1001>0; _ti_100_1001>>=1)
{
if (_tid<_ti_100_1001)
{
lwreds__stop[_tid]=(lwreds__stop[_tid]||lwreds__stop[(_tid+_ti_100_1001)]);
}
_ti_100_1003=(_ti_100_1002&1);
if (_ti_100_1003==1)
{
if (_tid==0)
{
lwreds__stop[_tid]=(lwreds__stop[_tid]||lwreds__stop[(_tid+(_ti_100_1002-1))]);
}
}
_ti_100_1002=_ti_100_1001;
if (_ti_100_1001>16)
{
barrier(CLK_LOCAL_MEM_FENCE);
}
}
if (_tid==0)
{
lgred__stop[_bid]=lwreds__stop[_tid];
}
}

