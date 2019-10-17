---
title: "AIWC for the masses"
subtitle: "Supporting HPC Architecture-Independent Workload Characterization on OpenMP, OpenACC, Cuda and OpenCL"
abstract: "

The next-generation of supercomputers will feature a diverse mix of accelerator devices.
These accelerators span an equally wide range of hardware properties.
Unfortunately, achieving good performance on these devices has historically used multiple programming languages, but in the present day results in fragmentation of implementation -- where an increasing amount of a programmers effort is expended to migrate codes between languages in order to examine performance of a new device when it hits the market.
We have previously shown that presenting the characteristics of a code in a architecture-independent fashion is useful to predict exection times.
From examining these highly accurate predictions we propose that Architecture-Independent Workload Characterization (AIWC) metrics are also useful in determining the suitability of a code and potential accelerators.
We show that the AIWC feature-space of each can provide a developer insights around the suitability of the kernel code when initially selecting for, then optimizing on, a specific accelerator.
To this end, we extend the usability of AIWC by supporting an additional programming language -- specifically, we examine how AIWC metrics change between CUDA and OpenCL implmentations of identical applications commonly used in scientific benchmarking.

"
keywords: "architecture independent workload characterization, portability, OpenCL, CUDA"
date: "`r format(Sys.time(), '%B %d, %Y')`"
bibliography: ./bibliography/bibliography.bib
---

<!--IEEE needs the keywords to be set here :(-->
\iftoggle{IEEE-BUILD}{
\begin{IEEEkeywords}
architecture independent workload characterization, portability, OpenCL, CUDA
\end{IEEEkeywords}
}{}


# Introduction

* AIWC already architecture independent
* LLVM common IR of all kernel codes 

# Methodology

## AIWC

* Brief about how AIWC currently operates LLVM OpenCL device simulator

## CUDA

Source-to-source translation tools:
cu2cl progress on CUDA rodinia bfs `/rodinia/cuda/bfs`:
`/cu2cl-build/cu2cl-build/cu2cl-tool bfs.cu ./kernel.cu  -- -I./ `
Results in `<command line>:7:10: fatal error: 'cuda_runtime.h' file not found`

##Coriander

We used Coriander to convert a subset of the Rodinia Benchmark suite from CUDA to OpenCL translation

The process is largely autonomous except it lacks support for `cudaMemcpyToSymbol` function calls.

Deprecated calls in the code-base to ``cudaThreadSynchronize`` also required replacing with ``cudaDeviceSynchronize``.
As such, the translation effort was almost entirely focused on replacing these operations with .
Manually replacing certain includes -- for instance `<math.h>` to `<cmath>` -- were needed for the translation effort since Coriander is tied to LLVM 3.9 and is hard-coded to only support C++11.
**TODO:** examine bfs (maybe fix invalid memory accesses)
**TODO:** list which demos weren't able to build using Coriander

##OpenARC

Open Accelerator Research Compiler (OpenARC) [@lee2014openarc]

### OpenMP 

* Steps taken to perform code translation from openmp to opencl kernel and wrapper

### OpenACC

Source code changes include C++ programs are unsupported as input programs, as such we need to change the `bfs` application extension.
Most of the translation was autonomous, only one explicit typecast for a user defined struct needed to be clarifed use 'struct' keyword to refer to the type.
Use of the preprocessor also doesn't work within OpenARC thus `TRANSFER_GRAPH_NODE` which was `typedef`ed to 1 was explicitly replaced.

TODO: summarise 
[WARNING] the current OpenARC implementation assumes that input programs follow ANSI C standard (a.k.a C89), which does not allow mixed declarations and code. However, the following procedures have mixed declarations. Please change the procedures such that all delaration statements comes before any expression statements; otherwise, incorrect translation may occur!



* Steps taken to perform code translation from openacc to opencl kernel and wrapper

# Evaluation

* Comparison in feature-spaces over Rodinia Benchmark Suite OpenCL vs
    + OpenACC
    + OpenMP
    + CUDA

# Results

# Conclusions and Future Work

We will apply the methodology of generating AIWC feature-spaces to other languages, specifically OpenMP and OpenACC -- since this is the typical means of accelerating conventional HPC workloads using many-core CPUs.
The ability to examine the characteristics of these kernels in large code-bases allow optimization work to occur on these kernels, effectively guiding a developers hand to optimize a code by providing strategies to minimise certain AIWC metrics shown to be advantageous to specific accelerators.
Additionally, examining the AIWC features of existing code-bases may facilitate identifying a better accelerator match as they become available.

# References
