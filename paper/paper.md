---
title: "AIWC for the masses"
subtitle: "Supporting HPC Architecture-Independent Workload Characterization on OpenMP, OpenACC, Cuda and OpenCL"
abstract: "

The next-generation of supercomputers will feature a diverse mix of accelerator devices.
These accelerators span an equally wide range of hardware properties.
Unfortunately, achieving good performance on these devices has historically used multiple programming languages, but in the present day results in fragmentation of implementation -- where an increasing amount of a programmer's effort is expended to migrate codes between languages in order to examine performance of a new device when it hits the market.
We have previously shown that presenting the characteristics of a code in a architecture-independent fashion is useful to predict exection times.
From examining these highly accurate predictions we propose that Architecture-Independent Workload Characterization (AIWC) metrics are also useful in determining the suitability of a code and potential accelerators.
We show that the AIWC feature-space of each can provide a developer insights around the suitability of the kernel code when initially selecting for, then optimizing on, a specific accelerator.
To this end, we extend the usability of AIWC by supporting an additional programming language -- specifically, we examine how AIWC metrics change between OpenMP, OpenACC, CUDA and OpenCL implmentations of identical applications commonly used in scientific benchmarking.

"
keywords: "architecture independent workload characterization, portability, OpenCL, CUDA, OpenACC, OpenMP"
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


### OpenACC

OpenACC [@OpenACC]

OpenACC~\cite{OpenACC} has been developed as a high-level directive-based alternative to low-level accelerator programming models. Lower-level approaches like CUDA and OpenCL typically require the programmer to explicitly manage mappings of parallelism and memory to device threads and memory, and require detailed knowledge about the target device. In contrast, OpenACC allows programmers to augment existing programs with directives to generically expose available parallelism, shifting the burden of thread and memory mapping to the underlying compiler. Because of its straightforward API and implications for performance portability, OpenACC has become an attractive option for domain scientists interested in exploring accelerator computing.

### OpenMP 
OpenMP [@dagum1998openmp]
OpenMP~\cite{dagum1998openmp} exists as one of the most widely-used tools in high-performance computing, in-part because of it's high-level directive-based approach and broad availability. While OpenMP has traditionally been used to generate multi-threaded code on CPU devices, the recent addition of offloading directives in the OpenMP 4.X+ standards has extended OpenMP to also support accelerator devices, primarily GPUs. Similarly to OpenACC, the OpenMP offloading directives provide a high-level alternative to low-level offloading models like OpenCl and CUDA, and provide existing OpenMP programmers a familiar entrance to accelerator computing.

##OpenARC

Open Accelerator Research Compiler (OpenARC) [@lee2014openarc]

The Open Accelerator Research Compiler (OpenARC)~\cite{lee2014openarc} has been developed as a research-oriented OpenACC and OpenMP compiler. OpenARC relies on source-to-source translations and code transformations to generate low-level device-optimized code, like CUDA or OpenCL, specific to a targeted device. OpenARC's primary strength is it's ability to enable rapid prototyping of novel ideas, features, and API extensions for emerging technologies.  

In this work, we leverage OpenARC's OpenACC to OpenCL and OpenMP to OpenCL translations using the AIWC system, which specializes in characterizing OpenCL workloads. This integration allows us to extend AIWC to characterize high-level codes written with OpenACC and OpenMP. 

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
