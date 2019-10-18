#ifndef __CUDA_KERNELHEADER__ 
#define __CUDA_KERNELHEADER__ 
/********************************************/
/* Added codes for OpenACC2CUDA translation */
/********************************************/
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

extern "C" __global__ void BFSGraph_kernel0(int lfpriv__no_of_nodes, _Bool * h_graph_mask, _Bool * h_graph_visited, _Bool * h_updating_graph_mask)
{
unsigned int lwpriv__i;
lwpriv__i=(threadIdx.x+(blockIdx.x*64));
#pragma acc  parallel loop num_workers(64) gang worker independent present(h_graph_mask[0:no_of_nodes], h_graph_visited[0:no_of_nodes], h_updating_graph_mask[0:no_of_nodes]) private(i) firstprivate(no_of_nodes) num_gangs(((int)ceil((((float)no_of_nodes)/64.0F))))
if (lwpriv__i<lfpriv__no_of_nodes)
{
h_updating_graph_mask[lwpriv__i]=0;
h_graph_mask[lwpriv__i]=0;
h_graph_visited[lwpriv__i]=0;
}
}

extern "C" __global__ void BFSGraph_kernel1(_Bool * h_graph_mask, _Bool * h_graph_visited, int source)
{
/* set the source node as true in the mask */
h_graph_mask[source]=1;
h_graph_visited[source]=1;
}

extern "C" __global__ void BFSGraph_kernel2(int lfpriv__no_of_nodes, int lfpriv__source, int * h_cost)
{
unsigned int lwpriv__i;
lwpriv__i=(threadIdx.x+(blockIdx.x*64));
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

extern "C" __global__ void BFSGraph_kernel3(int lfpriv__no_of_nodes, int * h_cost, int * h_graph_edges, _Bool * h_graph_mask, struct Node * h_graph_nodes, _Bool * h_graph_visited, _Bool * h_updating_graph_mask)
{
int lwpriv__tid;
lwpriv__tid=(threadIdx.x+(blockIdx.x*64));
#pragma acc  parallel loop num_workers(64) gang worker independent present(h_cost[0:no_of_nodes], h_graph_edges[0:edge_list_size], h_graph_mask[0:no_of_nodes], h_graph_nodes[0:no_of_nodes], h_graph_visited[0:no_of_nodes], h_updating_graph_mask[0:no_of_nodes]) private(tid) firstprivate(no_of_nodes) num_gangs(((int)ceil((((float)no_of_nodes)/64.0F))))
if (lwpriv__tid<lfpriv__no_of_nodes)
{
if (h_graph_mask[lwpriv__tid]==1)
{
int i;
h_graph_mask[lwpriv__tid]=0;
for (i=h_graph_nodes[lwpriv__tid].starting; i<(h_graph_nodes[lwpriv__tid].no_of_edges+h_graph_nodes[lwpriv__tid].starting); i ++ )
{
int id;
id=h_graph_edges[i];
if ( ! h_graph_visited[id])
{
h_cost[id]=(h_cost[lwpriv__tid]+1);
h_updating_graph_mask[id]=1;
}
}
}
}
}

extern "C" __global__ void BFSGraph_kernel4(_Bool * restrict lgred__stop, int lfpriv__no_of_nodes, _Bool * h_graph_mask, _Bool * h_graph_visited, _Bool * h_updating_graph_mask)
{
int lwpriv__tid;
int _bid;
int _bsize;
int _tid;
volatile _Bool __shared__ lwreds__stop[64];
int _ti_100_1001;
int _ti_100_1002;
int _ti_100_1003;
_tid=((threadIdx.x+(threadIdx.y*blockDim.x))+(threadIdx.z*(blockDim.x*blockDim.y)));
_bsize=((blockDim.x*blockDim.y)*blockDim.z);
_bid=((blockIdx.x+(blockIdx.y*gridDim.x))+(blockIdx.z*(gridDim.x*gridDim.y)));
lwreds__stop[_tid]=0;
lwpriv__tid=(threadIdx.x+(blockIdx.x*64));
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
__syncthreads();
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
if (_ti_100_1001>32)
{
__syncthreads();
}
}
if (_tid==0)
{
lgred__stop[_bid]=lwreds__stop[_tid];
}
}

