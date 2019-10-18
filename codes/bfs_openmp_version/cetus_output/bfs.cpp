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
#include <omp.h>
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


#endif 
/* End of __O2G_HEADER__ */


/* #define NUM_THREAD 4 */
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
fprintf(stderr, "Usage: %s <num_threads> <input_file>\n", argv[0]);
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

std::string kernel_str[0];
acc_init(acc_device_default, 0, kernel_str, "openarc_kernel");
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
int num_omp_threads;
unsigned int i;
if (argc!=3)
{
Usage(argc, argv);
exit(0);
}
num_omp_threads=atoi(argv[1]);
input_f=argv[2];
printf("Reading File\n");
/* Read in Graph from a file */
fp=fopen(input_f, "r");
if ( ! fp)
{
printf("Error Reading graph file\n");
return ;
}
int source = 0;
fscanf(fp, "%d", ( & no_of_nodes));
/* allocate host memory */
struct Node * h_graph_nodes;
h_graph_nodes=(struct Node *)malloc((sizeof (struct Node)*no_of_nodes));
_Bool * h_graph_mask;
h_graph_mask=(_Bool *)malloc((sizeof (_Bool)*no_of_nodes));
_Bool * h_updating_graph_mask;
h_updating_graph_mask=(_Bool *)malloc((sizeof (_Bool)*no_of_nodes));
_Bool * h_graph_visited;
h_graph_visited=(_Bool *)malloc((sizeof (_Bool)*no_of_nodes));
int start;
int edgeno;
/* initalize the memory */
for (i=0; i<no_of_nodes; i ++ )
{
fscanf(fp, "%d %d", ( & start), ( & edgeno));
h_graph_nodes[i].starting=start;
h_graph_nodes[i].no_of_edges=edgeno;
h_graph_mask[i]=0;
h_updating_graph_mask[i]=0;
h_graph_visited[i]=0;
}
/* read the source node from the file */
fscanf(fp, "%d", ( & source));
source=0;
/* set the source node as true in the mask */
h_graph_mask[source]=1;
h_graph_visited[source]=1;
fscanf(fp, "%d", ( & edge_list_size));
int id;
int cost;
int * h_graph_edges;
h_graph_edges=(int *)malloc((sizeof (int)*edge_list_size));
for (i=0; i<edge_list_size; i ++ )
{
fscanf(fp, "%d", ( & id));
fscanf(fp, "%d", ( & cost));
h_graph_edges[i]=id;
}
if (fp)
{
fclose(fp);
}
/* allocate mem for the result on host side */
int * h_cost;
h_cost=(int *)malloc((sizeof (int)*no_of_nodes));
for (i=0; i<no_of_nodes; i ++ )
{
h_cost[i]=( - 1);
}
h_cost[source]=0;
printf("Start traversing the tree\n");
int k = 0;
_Bool stop;
do
{
/* if no thread changes this value then the loop stops */
int tid;
stop=0;
omp_set_num_threads(num_omp_threads);
#pragma omp parallel for
for (tid=0; tid<no_of_nodes; tid ++ )
{
if (h_graph_mask[tid]==1)
{
int i;
h_graph_mask[tid]=0;
for (i=h_graph_nodes[tid].starting; i<(h_graph_nodes[tid].no_of_edges+h_graph_nodes[tid].starting); i ++ )
{
int id;
id=h_graph_edges[i];
if ( ! h_graph_visited[id])
{
h_cost[id]=(h_cost[tid]+1);
h_updating_graph_mask[id]=1;
}
}
}
}
for (tid=0; tid<no_of_nodes; tid ++ )
{
if (h_updating_graph_mask[tid]==1)
{
h_graph_mask[tid]=1;
h_graph_visited[tid]=1;
stop=1;
h_updating_graph_mask[tid]=0;
}
}
k ++ ;
}while(stop);

/* Store the result into a file */
FILE * fpo;
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

