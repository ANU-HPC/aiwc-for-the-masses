---
title: "AIWC for the masses"
subtitle: "Supporting HPC Architecture-Independent Workload Characterization on OpenMP, OpenACC, Cuda and OpenCL"
abstract: "


"
keywords: "vectorization, portability, OpenCL"
date: "`r format(Sys.time(), '%B %d, %Y')`"
bibliography: ./bibliography/bibliography.bib
---

<!--IEEE needs the keywords to be set here :(-->
\iftoggle{IEEE-BUILD}{
\begin{IEEEkeywords}
vectorization, portability, OpenCL
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

## OpenMP 

* Steps taken to perform code translation from openmp to opencl kernel and wrapper

## OpenACC

* Steps taken to perform code translation from openacc to opencl kernel and wrapper

# Evaluation

* Comparison in feature-spaces over Rodinia Benchmark Suite OpenCL vs
    + OpenACC
    + OpenMP
    + CUDA

# Results

# Conclusions

# References
