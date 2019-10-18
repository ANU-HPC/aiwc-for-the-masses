#ifndef __O2G_INCLUDE__ 
#define __O2G_INCLUDE__ 
/********************************************/
/* Header files for OpenACC2GPU translation */
/********************************************/
#include <openacc.h>
#include <openaccrt.h>
#include <math.h>
#include <float.h>
#include <limits.h>
#endif 
/* End of __O2G_INCLUDE__ */
/*
Copyright (C) 1991-2018 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it andor
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http:www.gnu.org/licenses/>. 
*/
/*
This header is separate from features.h so that the compiler can
   include it implicitly at the start of every compilation.  It must
   not itself include <features.h> or any other header that includes
   <features.h> because the implicit include comes before any feature
   test macros that may be defined in a source file before it first
   explicitly includes a system header.  GCC knows the name of this
   header in order to preinclude it. 
*/
/*
glibc's intent is to support the IEC 559 math functionality, real
   and complex.  If the GCC (4.9 and later) predefined macros
   specifying compiler intent are available, use them to determine
   whether the overall intent is to support these features; otherwise,
   presume an older compiler has intent to support these features and
   define these macros by default. 
*/
/*
wchar_t uses Unicode 10.0.0.  Version 10.0 of the Unicode Standard is
   synchronized with ISOIEC 10646:2017, fifth edition, plus
   the following additions from Amendment 1 to the fifth edition:
   - 56 emoji characters
   - 285 hentaigana
   - 3 additional Zanabazar Square characters
*/
/* We do not support C11 <threads.h>.  */
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include <stdbool.h>

#ifndef __O2G_HEADER__ 
#define __O2G_HEADER__ 
/*******************************************/
/* Codes added for OpenACC2GPU translation */
/*******************************************/
#define MAX(a,b) (((a) > (b)) ? (a) : (b))
#define MIN(a,b) (((a) < (b)) ? (a) : (b))
#define restrict __restrict__

/**********************************************************/
/* Maximum width of linear memory bound to texture memory */
/**********************************************************/
/* width in bytes */
#define LMAX_WIDTH    134217728
/**********************************/
/* Maximum memory pitch (in bytes)*/
/**********************************/
#define MAX_PITCH   262144
/****************************************/
/* Maximum allowed GPU global memory    */
/* (should be less than actual size ) */
/****************************************/
#define MAX_GMSIZE  1600000000
/****************************************/
/* Maximum allowed GPU shared memory    */
/****************************************/
#define MAX_SMSIZE  16384
/********************************************/
/* Maximum size of each dimension of a grid */
/********************************************/
#define MAX_GDIMENSION  65535

#define NUM_WORKERS  64

static unsigned long gpuNumThreads = NUM_WORKERS;
static unsigned long totalGpuNumThreads;
static unsigned long gpuNumBlocks;
static unsigned long gpuBytes = 0;
static int openarc_async;
static int openarc_waits[4];

#ifdef _OPENMP
#pragma omp threadprivate(gpuNumThreads, totalGpuNumThreads, gpuNumBlocks, gpuBytes, openarc_async, openarc_waits)
#endif

#endif 
/* End of __O2G_HEADER__ */


int no_of_nodes;
int edge_list_size;
FILE * fp;
/* Structure to hold a node information */
struct Node
{
int starting;
int no_of_edges;
};

void BFSGraph(int argc, char * * argv);
void Usage(int argc, char * * argv)
{
fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
return ;
}

/*  */
/* Main Program */
/*  */
int main(int argc, char * * argv)
{
int _ret_val_0 = 0;

//////////////////////////////////
// OpenCL Device Initialization //
//////////////////////////////////

std::string kernel_str[5];
kernel_str[4]="BFSGraph_kernel4";
kernel_str[3]="BFSGraph_kernel3";
kernel_str[2]="BFSGraph_kernel2";
kernel_str[1]="BFSGraph_kernel1";
kernel_str[0]="BFSGraph_kernel0";
acc_init(acc_device_default, 5, kernel_str, "openarc_kernel");
no_of_nodes=0;
edge_list_size=0;
BFSGraph(argc, argv);
acc_shutdown(acc_device_default);
return _ret_val_0;
}

/*  */
/* Apply BFS on a Graph using CUDA */
/*  */
void BFSGraph(int argc, char * * argv)
{
char * input_f;
int * h_cost;
int * h_graph_edges;
int source;
struct Node * h_graph_nodes;
_Bool * h_graph_mask;
_Bool * h_updating_graph_mask;
_Bool * h_graph_visited;
int start;
int edgeno;
int i;
int k;
_Bool stop;
int id;
int cost;
FILE * fpo;
int * gpu__h_graph_edges;
_Bool * gpu__h_graph_mask;
struct Node * gpu__h_graph_nodes;
_Bool * gpu__h_graph_visited;
_Bool * gpu__h_updating_graph_mask;
int * gpu__h_cost;
_Bool * ggred__stop = 0;
_Bool * extred__stop = 0;
int _ti_100_1000;
if (argc!=2)
{
Usage(argc, argv);
exit(0);
}
input_f=argv[1];
printf("Reading File\n");
/* Read in Graph from a file */
fp=fopen(input_f, "r");
if ( ! fp)
{
printf("Error Reading graph file\n");
return ;
}
source=0;
fscanf(fp, "%d", ( & no_of_nodes));
/* allocate host memory */
h_graph_nodes=((struct Node *)malloc((sizeof (struct Node)*no_of_nodes)));
h_graph_mask=((_Bool *)malloc((sizeof (_Bool)*no_of_nodes)));
h_updating_graph_mask=((_Bool *)malloc((sizeof (_Bool)*no_of_nodes)));
h_graph_visited=((_Bool *)malloc((sizeof (_Bool)*no_of_nodes)));
/* initalize the memory */
for (i=0; i<no_of_nodes; i ++ )
{
fscanf(fp, "%d %d", ( & start), ( & edgeno));
h_graph_nodes[i].starting=start;
h_graph_nodes[i].no_of_edges=edgeno;
}
/* read the source node from the file */
fscanf(fp, "%d", ( & source));
source=0;
fscanf(fp, "%d", ( & edge_list_size));
h_graph_edges=((int *)malloc((sizeof (int)*edge_list_size)));
for (i=0; i<edge_list_size; i ++ )
{
fscanf(fp, "%d", ( & id));
fscanf(fp, "%d", ( & cost));
h_graph_edges[i]=id;
}
h_cost=((int *)malloc((sizeof (int)*no_of_nodes)));
if (fp)
{
fclose(fp);
}
printf("h_updating_graph_mask %i\n", h_updating_graph_mask[0]);
printf("h_graph_visited %i\n", h_graph_visited[0]);
gpuBytes=(sizeof (int)*edge_list_size);
HI_malloc1D(h_graph_edges, ((void * *)( & gpu__h_graph_edges)), gpuBytes, DEFAULT_QUEUE, HI_MEM_READ_WRITE);
gpuBytes=(sizeof (_Bool)*no_of_nodes);
HI_malloc1D(h_graph_mask, ((void * *)( & gpu__h_graph_mask)), gpuBytes, DEFAULT_QUEUE, HI_MEM_READ_WRITE);
gpuBytes=(sizeof (struct Node)*no_of_nodes);
HI_malloc1D(h_graph_nodes, ((void * *)( & gpu__h_graph_nodes)), gpuBytes, DEFAULT_QUEUE, HI_MEM_READ_WRITE);
gpuBytes=(sizeof (_Bool)*no_of_nodes);
HI_malloc1D(h_graph_visited, ((void * *)( & gpu__h_graph_visited)), gpuBytes, DEFAULT_QUEUE, HI_MEM_READ_WRITE);
gpuBytes=(sizeof (_Bool)*no_of_nodes);
HI_malloc1D(h_updating_graph_mask, ((void * *)( & gpu__h_updating_graph_mask)), gpuBytes, DEFAULT_QUEUE, HI_MEM_READ_WRITE);
gpuBytes=(sizeof (int)*no_of_nodes);
HI_malloc1D(h_cost, ((void * *)( & gpu__h_cost)), gpuBytes, DEFAULT_QUEUE, HI_MEM_READ_WRITE);
size_t dimGrid_BFSGraph_kernel0[3];
dimGrid_BFSGraph_kernel0[0]=((int)ceil((((float)no_of_nodes)/64.0F)));
dimGrid_BFSGraph_kernel0[1]=1;
dimGrid_BFSGraph_kernel0[2]=1;
size_t dimBlock_BFSGraph_kernel0[3];
dimBlock_BFSGraph_kernel0[0]=64;
dimBlock_BFSGraph_kernel0[1]=1;
dimBlock_BFSGraph_kernel0[2]=1;
gpuNumBlocks=((int)ceil((((float)no_of_nodes)/64.0F)));
gpuNumThreads=64;
totalGpuNumThreads=(((int)ceil((((float)no_of_nodes)/64.0F)))*64);
size_t dimGrid_BFSGraph_kernel1[3];
dimGrid_BFSGraph_kernel1[0]=1;
dimGrid_BFSGraph_kernel1[1]=1;
dimGrid_BFSGraph_kernel1[2]=1;
size_t dimBlock_BFSGraph_kernel1[3];
dimBlock_BFSGraph_kernel1[0]=1;
dimBlock_BFSGraph_kernel1[1]=1;
dimBlock_BFSGraph_kernel1[2]=1;
gpuNumBlocks=1;
gpuNumThreads=1;
totalGpuNumThreads=1;
size_t dimGrid_BFSGraph_kernel2[3];
dimGrid_BFSGraph_kernel2[0]=((int)ceil((((float)no_of_nodes)/64.0F)));
dimGrid_BFSGraph_kernel2[1]=1;
dimGrid_BFSGraph_kernel2[2]=1;
size_t dimBlock_BFSGraph_kernel2[3];
dimBlock_BFSGraph_kernel2[0]=64;
dimBlock_BFSGraph_kernel2[1]=1;
dimBlock_BFSGraph_kernel2[2]=1;
gpuNumBlocks=((int)ceil((((float)no_of_nodes)/64.0F)));
gpuNumThreads=64;
totalGpuNumThreads=(((int)ceil((((float)no_of_nodes)/64.0F)))*64);
size_t dimGrid_BFSGraph_kernel3[3];
dimGrid_BFSGraph_kernel3[0]=((int)ceil((((float)no_of_nodes)/64.0F)));
dimGrid_BFSGraph_kernel3[1]=1;
dimGrid_BFSGraph_kernel3[2]=1;
size_t dimBlock_BFSGraph_kernel3[3];
dimBlock_BFSGraph_kernel3[0]=64;
dimBlock_BFSGraph_kernel3[1]=1;
dimBlock_BFSGraph_kernel3[2]=1;
gpuNumBlocks=((int)ceil((((float)no_of_nodes)/64.0F)));
gpuNumThreads=64;
totalGpuNumThreads=(((int)ceil((((float)no_of_nodes)/64.0F)))*64);
size_t dimGrid_BFSGraph_kernel4[3];
dimGrid_BFSGraph_kernel4[0]=((int)ceil((((float)no_of_nodes)/64.0F)));
dimGrid_BFSGraph_kernel4[1]=1;
dimGrid_BFSGraph_kernel4[2]=1;
size_t dimBlock_BFSGraph_kernel4[3];
dimBlock_BFSGraph_kernel4[0]=64;
dimBlock_BFSGraph_kernel4[1]=1;
dimBlock_BFSGraph_kernel4[2]=1;
gpuNumBlocks=((int)ceil((((float)no_of_nodes)/64.0F)));
gpuNumThreads=64;
totalGpuNumThreads=(((int)ceil((((float)no_of_nodes)/64.0F)))*64);
gpuBytes=(gpuNumBlocks*sizeof (_Bool));
HI_tempMalloc1D(((void * *)( & ggred__stop)), gpuBytes, acc_device_current);
HI_tempMalloc1D(((void * *)( & extred__stop)), gpuBytes, acc_device_host);
#pragma acc  data copyout(h_cost[0:no_of_nodes]) create(h_graph_edges[0:edge_list_size], h_graph_mask[0:no_of_nodes], h_graph_nodes[0:no_of_nodes], h_graph_visited[0:no_of_nodes], h_updating_graph_mask[0:no_of_nodes])
{
HI_set_async(1);
if (HI_get_device_address(h_graph_nodes, ((void * *)( & gpu__h_graph_nodes)), 1)!=HI_success)
{
printf("[ERROR] GPU memory for the host variable, h_graph_nodes, does not exist. \n");
printf("Enclosing annotation: \n#pragma acc  update async(1) device(h_graph_nodes[0:no_of_nodes]) \n");
exit(1);
}
gpuBytes=(sizeof (struct Node)*no_of_nodes);
HI_memcpy_async(gpu__h_graph_nodes, h_graph_nodes, gpuBytes, HI_MemcpyHostToDevice, 0, 1);
#pragma acc  update async(1) device(h_graph_nodes[0:no_of_nodes])
HI_register_kernel_numargs("BFSGraph_kernel0",4);
HI_register_kernel_arg("BFSGraph_kernel0",0,sizeof (int),( & no_of_nodes),0);
HI_register_kernel_arg("BFSGraph_kernel0",1,sizeof(void*),( & gpu__h_graph_mask),1);
HI_register_kernel_arg("BFSGraph_kernel0",2,sizeof(void*),( & gpu__h_graph_visited),1);
HI_register_kernel_arg("BFSGraph_kernel0",3,sizeof(void*),( & gpu__h_updating_graph_mask),1);
HI_kernel_call("BFSGraph_kernel0",dimGrid_BFSGraph_kernel0,dimBlock_BFSGraph_kernel0,DEFAULT_QUEUE);
HI_synchronize(0);
gpuNumBlocks=((int)ceil((((float)no_of_nodes)/64.0F)));
if (HI_get_device_address(h_graph_mask, ((void * *)( & gpu__h_graph_mask)), DEFAULT_QUEUE)!=HI_success)
{
printf("[ERROR] GPU memory for the host variable, h_graph_mask, does not exist. \n");
printf("Enclosing annotation: \n#pragma acc  data copyin(source) present(h_graph_mask[0:no_of_nodes], h_graph_visited[0:no_of_nodes]) \n");
exit(1);
}
if (HI_get_device_address(h_graph_visited, ((void * *)( & gpu__h_graph_visited)), DEFAULT_QUEUE)!=HI_success)
{
printf("[ERROR] GPU memory for the host variable, h_graph_visited, does not exist. \n");
printf("Enclosing annotation: \n#pragma acc  data copyin(source) present(h_graph_mask[0:no_of_nodes], h_graph_visited[0:no_of_nodes]) \n");
exit(1);
}
#pragma acc  data copyin(source) present(h_graph_mask[0:no_of_nodes], h_graph_visited[0:no_of_nodes])
{
#pragma acc  parallel num_workers(1) copyin(source) present(h_graph_mask[0:no_of_nodes], h_graph_visited[0:no_of_nodes]) num_gangs(1)
HI_register_kernel_numargs("BFSGraph_kernel1",3);
HI_register_kernel_arg("BFSGraph_kernel1",0,sizeof(void*),( & gpu__h_graph_mask),1);
HI_register_kernel_arg("BFSGraph_kernel1",1,sizeof(void*),( & gpu__h_graph_visited),1);
HI_register_kernel_arg("BFSGraph_kernel1",2,sizeof (int),( & source),0);
HI_kernel_call("BFSGraph_kernel1",dimGrid_BFSGraph_kernel1,dimBlock_BFSGraph_kernel1,DEFAULT_QUEUE);
HI_synchronize(0);
gpuNumBlocks=1;
}
/* allocate mem for the result on host side */
HI_register_kernel_numargs("BFSGraph_kernel2",3);
HI_register_kernel_arg("BFSGraph_kernel2",0,sizeof (int),( & no_of_nodes),0);
HI_register_kernel_arg("BFSGraph_kernel2",1,sizeof (int),( & source),0);
HI_register_kernel_arg("BFSGraph_kernel2",2,sizeof(void*),( & gpu__h_cost),1);
HI_kernel_call("BFSGraph_kernel2",dimGrid_BFSGraph_kernel2,dimBlock_BFSGraph_kernel2,DEFAULT_QUEUE);
HI_synchronize(0);
gpuNumBlocks=((int)ceil((((float)no_of_nodes)/64.0F)));
/* finish transfer node and edge to target */
if (HI_get_device_address(h_graph_edges, ((void * *)( & gpu__h_graph_edges)), DEFAULT_QUEUE)!=HI_success)
{
printf("[ERROR] GPU memory for the host variable, h_graph_edges, does not exist. \n");
printf("Enclosing annotation: \n#pragma acc  update device(h_graph_edges[0:edge_list_size]) \n");
exit(1);
}
gpuBytes=(sizeof (int)*edge_list_size);
HI_memcpy(gpu__h_graph_edges, h_graph_edges, gpuBytes, HI_MemcpyHostToDevice, 0);
#pragma acc  update device(h_graph_edges[0:edge_list_size])
#pragma acc  wait(1)
acc_wait(1);
printf("Start traversing the tree\n");
k=0;
do
{
/* if no thread changes this value then the loop stops */
stop=0;
HI_register_kernel_numargs("BFSGraph_kernel3",8);
HI_register_kernel_arg("BFSGraph_kernel3",0,sizeof (int),( & id),0);
HI_register_kernel_arg("BFSGraph_kernel3",1,sizeof (int),( & no_of_nodes),0);
HI_register_kernel_arg("BFSGraph_kernel3",2,sizeof(void*),( & gpu__h_cost),1);
HI_register_kernel_arg("BFSGraph_kernel3",3,sizeof(void*),( & gpu__h_graph_edges),1);
HI_register_kernel_arg("BFSGraph_kernel3",4,sizeof(void*),( & gpu__h_graph_mask),1);
HI_register_kernel_arg("BFSGraph_kernel3",5,sizeof(void*),( & gpu__h_graph_nodes),1);
HI_register_kernel_arg("BFSGraph_kernel3",6,sizeof(void*),( & gpu__h_graph_visited),1);
HI_register_kernel_arg("BFSGraph_kernel3",7,sizeof(void*),( & gpu__h_updating_graph_mask),1);
HI_kernel_call("BFSGraph_kernel3",dimGrid_BFSGraph_kernel3,dimBlock_BFSGraph_kernel3,DEFAULT_QUEUE);
HI_synchronize(0);
gpuNumBlocks=((int)ceil((((float)no_of_nodes)/64.0F)));
HI_register_kernel_numargs("BFSGraph_kernel4",5);
HI_register_kernel_arg("BFSGraph_kernel4",0,sizeof(void*),( & ggred__stop),1);
HI_register_kernel_arg("BFSGraph_kernel4",1,sizeof (int),( & no_of_nodes),0);
HI_register_kernel_arg("BFSGraph_kernel4",2,sizeof(void*),( & gpu__h_graph_mask),1);
HI_register_kernel_arg("BFSGraph_kernel4",3,sizeof(void*),( & gpu__h_graph_visited),1);
HI_register_kernel_arg("BFSGraph_kernel4",4,sizeof(void*),( & gpu__h_updating_graph_mask),1);
HI_kernel_call("BFSGraph_kernel4",dimGrid_BFSGraph_kernel4,dimBlock_BFSGraph_kernel4,DEFAULT_QUEUE);
HI_synchronize(0);
gpuNumBlocks=((int)ceil((((float)no_of_nodes)/64.0F)));
gpuBytes=(gpuNumBlocks*sizeof (_Bool));
HI_memcpy(extred__stop, ggred__stop, gpuBytes, HI_MemcpyDeviceToHost, 0);
for (_ti_100_1000=0; _ti_100_1000<gpuNumBlocks; _ti_100_1000 ++ )
{
stop=(stop||extred__stop[_ti_100_1000]);
}
k ++ ;
}while(stop);

}
HI_tempFree(((void * *)( & ggred__stop)), acc_device_current);
HI_tempFree(((void * *)( & extred__stop)), acc_device_host);
gpuBytes=(sizeof (int)*no_of_nodes);
HI_memcpy(h_cost, gpu__h_cost, gpuBytes, HI_MemcpyDeviceToHost, 0);
HI_free(h_cost, DEFAULT_QUEUE);
HI_free(h_updating_graph_mask, DEFAULT_QUEUE);
HI_free(h_graph_visited, DEFAULT_QUEUE);
HI_free(h_graph_nodes, DEFAULT_QUEUE);
HI_free(h_graph_mask, DEFAULT_QUEUE);
HI_free(h_graph_edges, DEFAULT_QUEUE);
/* end acc data */
/* Store the result into a file */
fpo=fopen("result.txt", "w");
for (i=0; i<no_of_nodes; i ++ )
{
fprintf(fpo, "%d) cost:%d\n", i, h_cost[i]);
}
fclose(fpo);
printf("Result stored in result.txt\n");
/* cleanup memory */
free(h_graph_nodes);
free(h_graph_edges);
free(h_graph_mask);
free(h_updating_graph_mask);
free(h_graph_visited);
free(h_cost);
return ;
}

