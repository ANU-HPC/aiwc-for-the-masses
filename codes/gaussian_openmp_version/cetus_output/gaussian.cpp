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
/*
-----------------------------------------------------------
 gaussian.c -- The program is to solve a linear system Ax = b
 **   by using Gaussian Elimination. The algorithm on page 101
 **   ("Foundations of Parallel Programming") is used.  
 **   The sequential version is gaussian.c.  This parallel 
 **   implementation converts three independent for() loops 
 **   into three Fans.  Use the data file ge_3.dat to verify 
 **   the correction of the output. 
 **
 ** Written by Andreas Kura, 02/15/95
 ** Modified by Chong-wei Xu, 04/20/95
 ** Modified by Chris Gregg for CUDA, 07/20/2009
 ** Modified by Pisit Makpaisit for OpenACC, 08/05/2013
 ** Modified by Beau Johnston for OpenMP, 01/10/2019
 **-----------------------------------------------------------

*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <string.h>

#ifndef __O2G_HEADER__ 
#define __O2G_HEADER__ 
/*******************************************/
/* Codes added for OpenACC2GPU translation */
/*******************************************/
#define MAX(a,b) (((a) > (b)) ? (a) : (b))
#define MIN(a,b) (((a) < (b)) ? (a) : (b))
#ifdef __cplusplus
#define restrict __restrict__
#endif

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


int Size;
float * a;
float * b;
float * finalVec;
float * m;
FILE * fp;
void InitProblemOnce(char * filename);
void InitPerRun(float * m);
void ForwardSub();
void BackSub();
void Fan1(float * m, float * a, int Size, int t);
void Fan2(float * m, float * a, float * b, int Size, int j1, int t);
void InitMat(float * ary, int nrow, int ncol);
void InitAry(float * ary, int ary_size);
void PrintMat(float * ary, int nrow, int ncolumn);
void PrintAry(float * ary, int ary_size);
unsigned int totalKernelTime = 0;
int main(int argc, char * argv[])
{
struct timeval time_start;
struct timeval time_end;
unsigned int time_total;
int verbose = 1;
int _ret_val_0 = 0;

////////////////////////////////
// CUDA Device Initialization //
////////////////////////////////

std::string kernel_str[0];
acc_init(acc_device_nvidia, 0, kernel_str, "openarc_kernel");
if (argc<2)
{
printf("Usage: gaussian matrix.txt [-q]\n\n");
printf("-q (quiet) suppresses printing the matrix and result values.\n");
printf("The first line of the file contains the dimension of the matrix, n.");
printf("The second line of the file is a newline.\n");
printf("The next n lines contain n tab separated values for the matrix.");
printf("The next line of the file is a newline.\n");
printf("The next line of the file is a 1xn vector with tab separated values.\n");
printf("The next line of the file is a newline. (optional)\n");
printf("The final line of the file is the pre-computed solution. (optional)\n");
printf("Example: matrix4.txt:\n");
printf("4\n");
printf("\n");
printf("-0.6	-0.5	0.7	0.3\n");
printf("-0.3	-0.9	0.3	0.7\n");
printf("-0.4	-0.5	-0.3	-0.8\n");
printf("0.0	-0.1	0.2	0.9\n");
printf("\n");
printf("-0.85	-0.68	0.24	-0.53\n");
printf("\n");
printf("0.7	0.0	-0.4	-0.5\n");
exit(0);
}
/* char filename[100]; */
/* sprintf(filename,"matricesmatrix%d.txt",size); */
InitProblemOnce(argv[1]);
if (argc>2)
{
if ( ! strcmp(argv[2], "-q"))
{
verbose=0;
}
}
/* InitProblemOnce(filename); */
InitPerRun(m);
/* begin timing */
gettimeofday(( & time_start), 0);
/* run kernels */
ForwardSub();
/* end timing */
gettimeofday(( & time_end), 0);
time_total=(((time_end.tv_sec*1000000)+time_end.tv_usec)-((time_start.tv_sec*1000000)+time_start.tv_usec));
if (verbose)
{
printf("Matrix m is: \n");
PrintMat(m, Size, Size);
printf("Matrix a is: \n");
PrintMat(a, Size, Size);
printf("Array b is: \n");
PrintAry(b, Size);
}
BackSub();
if (verbose)
{
printf("The final solution is: \n");
PrintAry(finalVec, Size);
}
printf("\nTime total (including memory transfers)\t%f sec\n", (time_total*1.0E-6));
printf("Time for kernels:\t%f sec\n", (totalKernelTime*1.0E-6));
/*
printf("%d,%d\n",size,time_total);
    fprintf(stderr,"%d,%d\n",size,time_total);
*/
free(m);
free(a);
free(b);
acc_shutdown(acc_device_nvidia);
return _ret_val_0;
}

/*
------------------------------------------------------
 InitProblemOnce -- Initialize all of matrices and
 ** vectors by opening a data file specified by the user.
 **
 ** We used dynamic array *a, *b, and *m to allocate
 ** the memory storages.
 **------------------------------------------------------

*/
void InitProblemOnce(char * filename)
{
/* charfilename = argv[1]; */
/* printf("Enter the data file name: "); */
/* scanf("%s", filename); */
/* printf("The file name is: %s\n", filename); */
fp=fopen(filename, "r");
fscanf(fp, "%d", ( & Size));
a=((float *)malloc(((Size*Size)*sizeof (float))));
InitMat(a, Size, Size);
/* printf("The input matrix a is:\n"); */
/* PrintMat(a, Size, Size); */
b=((float *)malloc((Size*sizeof (float))));
InitAry(b, Size);
/* printf("The input array b is:\n"); */
/* PrintAry(b, Size); */
m=((float *)malloc(((Size*Size)*sizeof (float))));
return ;
}

/*
------------------------------------------------------
 InitPerRun() -- Initialize the contents of the
 ** multipier matrix **m
 **------------------------------------------------------

*/
void InitPerRun(float * m)
{
int i;
for (i=0; i<(Size*Size); i ++ )
{
( * (m+i))=0.0;
}
return ;
}

/*
-------------------------------------------------------
 Fan1() -- Calculate multiplier matrix
 ** Pay attention to the index.  Index i give the range
 ** which starts from 0 to range-1.  The real values of
 ** the index should be adjust and related with the value
 ** of t which is defined on the ForwardSub().
 **-------------------------------------------------------

*/
void Fan1(float * m, float * a, int Size, int t)
{
int i;
#pragma omp parallel for shared(a, m)
for (i=0; i<((Size-1)-t); i ++ )
{
m[((Size*((i+t)+1))+t)]=(a[((Size*((i+t)+1))+t)]/a[((Size*t)+t)]);
}
return ;
}

/*
-------------------------------------------------------
 Fan2() -- Modify the matrix A into LUD
 **-------------------------------------------------------

*/
void Fan2(float * m, float * a, float * b, int Size, int j1, int t)
{
int i;
int j;
/* #pragma omp parallel loop present(m,a) */
for (i=0; i<((Size-1)-t); i ++ )
{
/* #pragma omp loop */
for (j=0; j<(Size-t); j ++ )
{
a[((Size*((i+1)+t))+(j+t))]-=(m[((Size*((i+1)+t))+t)]*a[((Size*t)+(j+t))]);
}
}
/* #pragma omp parallel loop present(m,b) */
for (i=0; i<((Size-1)-t); i ++ )
{
b[((i+1)+t)]-=(m[((Size*((i+1)+t))+t)]*b[t]);
}
return ;
}

/*
------------------------------------------------------
 ForwardSub() -- Forward substitution of Gaussian
 ** elimination.
 **------------------------------------------------------

*/
void ForwardSub()
{
int t;
/* #pragma omp data copy(m[0:SizeSize],a[0:Size*Size],b[0:Size]) */
{
/* begin timing kernels */
struct timeval time_start;
gettimeofday(( & time_start), 0);
for (t=0; t<(Size-1); t ++ )
{
Fan1(m, a, Size, t);
Fan2(m, a, b, Size, (Size-t), t);
}
/* end timing kernels */
struct timeval time_end;
gettimeofday(( & time_end), 0);
totalKernelTime=(((time_end.tv_sec*1000000)+time_end.tv_usec)-((time_start.tv_sec*1000000)+time_start.tv_usec));
}
/* end omp data */
return ;
}

/*
------------------------------------------------------
 BackSub() -- Backward substitution
 **------------------------------------------------------

*/
void BackSub()
{
/* create a new vector to hold the final answer */
finalVec=((float *)malloc((Size*sizeof (float))));
/* solve "bottom up" */
int i;
int j;
for (i=0; i<Size; i ++ )
{
finalVec[((Size-i)-1)]=b[((Size-i)-1)];
for (j=0; j<i; j ++ )
{
finalVec[((Size-i)-1)]-=(( * ((a+(Size*((Size-i)-1)))+((Size-j)-1)))*finalVec[((Size-j)-1)]);
}
finalVec[((Size-i)-1)]=(finalVec[((Size-i)-1)]/( * ((a+(Size*((Size-i)-1)))+((Size-i)-1))));
}
return ;
}

void InitMat(float * ary, int nrow, int ncol)
{
int i;
int j;
for (i=0; i<nrow; i ++ )
{
for (j=0; j<ncol; j ++ )
{
fscanf(fp, "%f", ((ary+(Size*i))+j));
}
}
return ;
}

/*
------------------------------------------------------
 PrintMat() -- Print the contents of the matrix
 **------------------------------------------------------

*/
void PrintMat(float * ary, int nrow, int ncol)
{
int i;
int j;
for (i=0; i<nrow; i ++ )
{
for (j=0; j<ncol; j ++ )
{
printf("%8.2f ", ( * ((ary+(Size*i))+j)));
}
printf("\n");
}
printf("\n");
return ;
}

/*
------------------------------------------------------
 InitAry() -- Initialize the array (vector) by reading
 ** data from the data file
 **------------------------------------------------------

*/
void InitAry(float * ary, int ary_size)
{
int i;
for (i=0; i<ary_size; i ++ )
{
fscanf(fp, "%f", ( & ary[i]));
}
return ;
}

/*
------------------------------------------------------
 PrintAry() -- Print the contents of the array (vector)
 **------------------------------------------------------

*/
void PrintAry(float * ary, int ary_size)
{
int i;
for (i=0; i<ary_size; i ++ )
{
printf("%.2f ", ary[i]);
}
printf("\n\n");
return ;
}

