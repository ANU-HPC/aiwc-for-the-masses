---
#title: "AIWC for the Masses: Supporting Architecture-Independent Workload Characterization on OpenMP, OpenACC, CUDA and OpenCL"
title: "Towards Language-Agnostic Architecture-Independent Workload Characterization for HPC Accelerators"

abstract: "

The next-generation of supercomputers will feature a diverse mix of accelerator devices.
These accelerators span an equally wide range of hardware properties.
Unfortunately, achieving good performance on these devices has historically required multiple programming languages with a separate implementation for each device. In the present day this results in the fragmentation of implementation -- where an increasing amount of a programmer's effort is expended to migrate codes between languages in order to use a new device.
We have previously shown that presenting the characteristics of a code in a architecture-independent fashion is useful to predict execution times.
From examining these highly accurate predictions we propose that Architecture-Independent Workload Characterization (AIWC) metrics are also useful in determining the suitability of a code for potential accelerators.
To this end, we extend the usability of AIWC by supporting additional programming languages common to accelerator-based High-Performance Computing (HPC).
We use two compilers to perform source-to-source level translation from CUDA-to-OpenCL, OpenMP-to-OpenCL and OpenACC-to-OpenCL and extend the usefulness of the AIWC tool by evaluating the base execution behaviour on these outputs.
Essentially, we examine how AIWC metrics change between OpenMP, OpenACC, CUDA and OpenCL implementations of identical applications.
This is useful to guide a developer through optimizations, extend predictions for scheduling over languages and evaluate differences between compilers, frameworks and toolchains.

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
\newcommand{\figcolumnwidth}{\columnwidth}
\newcommand\skipper{0.5em}
\newcommand\bigskipper{1em}
}{}

\iftoggle{ACM-BUILD}{
\renewcommand{\shorttitle}{AIWC for the Masses}
\newcommand\figcolumnwidth{0.95\columnwidth}
\newcommand\skipper{1em}
\newcommand\bigskipper{2em}
}{}
\newcommand\qcolumnwidth{0.4\columnwidth}

# Introduction

High-Performance Computing (HPC) today is dominated by closed, proprietary software models.
Despite OpenCL having existed for over a decade, it has generated little traction/adoption by the scientific programming community at large. 
Fragmentation between implementations of scientific codes already exists. 
Many lines of legacy code have already been reimplemented in accelerator directive-based languages such as OpenACC and OpenMP, while some computationally intensive kernels have been implemented in CUDA.
Unfortunately, many of these codes must frequently target new accelerators, as supercomputers are rapidly updated, and the accelerators used on a node are just as quickly replaced -- often by different vendors and likely another class of accelerator (MIC, GPU or FPGA).
We can easily imagine a world where developers at universities, in industry and research laboratories will have full-time jobs rewriting the same codes on loop, taking years optimising and rewriting kernels for the upcoming system.
This demand will only grow as the HPC center's dependence on heterogeneous accelerator architectures increases, pushed by energy-efficiency requirements in the era of exascale computing, and is untenable.

Workload characterization is an important tool to examine the fundamental behaviour of a code and its underlying structure. It facilitates identifying performance-limiting factors -- an understanding of which is critical when considering the portability between accelerators.
Characterization, in this setting, occurs by examining the LLVM execution traces on an abstract OpenCL device and tracking and recording statistics about the fundamental nature of these codes.
For instance, a code with regular memory accesses and predictable branching that is highly parallel (utilizing a large number of threads) is a suitable candidate for selection for a GPU type of accelerator. Conversely, inherently serial tasks are more suited for CPU devices which commonly offer a higher clock-speed. 
In the past we have used Architecture-Independent Workload Characterization (AIWC) to perform accurate run-time predictions of OpenCL codes over multiple accelerators -- motivated by the goal of automatically scheduling kernels to the most appropriate accelerator on an HPC system based on these essential characteristics.
We have also shown that these characteristics are useful in guiding a developer's efforts in optimizing performance on accelerators by outlining the potential bottlenecks of the implementation of an algorithm (in the amount of parallelism available, memory access patterns and scaling over problem sizes, etc).
Unfortunately, both motivations will be undone without industry adoption and community support for the OpenCL runtime.

Standard Portable Intermediate Representation (SPIR) is an intermediate language for parallel compute and graphics by Khronos Group, primarily treated as an abstract LLVM based subset of codes to allow portable transitions between OpenCL supported devices.
It is low-level enough for general compiler optimizations to occur, but is more abstract than the allocation registers and micro-architecture-specific optimizations.
Recent advances with SYCL, HIP/ROCM, and oneAPI may increase adoption of open-source models and present an alternative to the OpenCL-only characterization approach.
These frameworks are also based on the SPIR representation, support the OpenCL runtime and memory model, and can be leveraged by the AIWC and Oclgrind debugging tools.
Meanwhile, compilers are maturing and are increasingly able to provide source-to-source translations and code transformations, to generate low-level device-optimized code, and to allow implementations in one language to be mapped to another. The goal of this project is to extend AIWC support for all languages (1) by assessing the AIWC feature-space outputs of contemporary source-to-source compiler/translator tools, and (2) by exploring any differences compared to a native OpenCL implementation to identify any potential inefficiencies of the translation by these tools.

In summary, in this project we extend the use of AIWC to evaluate the current state-of-the-art in source-to-source translation. Primarily we examine the feasibility of leveraging existing language implementations of codes that automatically map back to OpenCL. In Section\ \ref{sec:languages} we summarize the common languages used on accelerators and quantitatively survey the community's interest in each. This is done to motivate our interest in tooling and offering support for frameworks that rely on back-end generation of SPIR codes. In Section\ \ref{sec:related} we discuss related work. In Section\ \ref{sec:methodology} we present our methodology, highlighting our selection of source-to-source translation tools used in our experiments and discuss changes made to the implementations to support these tools. We present our results in Section\ \ref{sec:results}, and conclude in Section\ \ref{sec:conclusion} with a summary of our findings and the directions for future work. 

# Accelerator Programming Frameworks and their Adoption <!--Adoption Survey--> {#sec:languages}

<!--## CUDA-->

CUDA\ [@cuda] -- NVIDIA's proprietary software model -- has been around since 2007.
It has been widely adopted by the scientific community as a means to repurpose GPUs from traditional rendering in gaming workloads to highly-parallel compute intensive tasks common to scientific codes. Unfortunately, it is a single-vendor language, thus CUDA codes are executed solely on NVIDIA devices. There has been some recent activity by AMD with their ROCm software stack to provide an alternative. For example, their Hipify tool automatically generates a HIP (Heterogeneous-Compute Interface for Portability) representation -- an AMD defined standard -- from input CUDA code. 

<!--## OpenCL-->

OpenCL\ [@opencl] (Open Compute Language) was introduced shortly after CUDA (in 2009) as a standard agreed upon by accelerator vendors. This ideally allowing a code to be written once and executed on any (OpenCL complaint) device. Vendors typically each develop their own-backend OpenCL runtime. This can result in greater variation in performance since vendors can choose their extent of support and optimization. To remedy this POCL (Portable Computing Language) is an Open Source initiative providing an implementation of the OpenCL standard. POCL's relationship to OpenCL is analogous to HIPs relationship to CUDA -- both leverage Clang and LLVM, Clang for the front-end compilation of codes and LLVM for the kernel compiler implementation. POCL offers backends to NVIDIA devices (via a mapping of LLVM to CUDA/PTX), HSA (Heterogeneous System Architecture) GPUs such as those offered by ARM and AMD, along with CPUs and ASIPs (Application-Specific Instruction-set Processor).

<!--## OpenACC -->

OpenACC\ [@OpenACC] has been developed as a high-level directive-based alternative to low-level accelerator programming models. Lower-level approaches like CUDA and OpenCL typically require the programmer to explicitly manage mappings of parallelism and memory to device threads and memory, and require detailed knowledge about the target device. In contrast, OpenACC allows programmers to augment existing programs with directives to generically expose available parallelism, shifting the burden of thread and memory mapping to the underlying compiler. Because of its straightforward API and implications for performance portability, OpenACC has become an attractive option for domain scientists interested in exploring accelerator computing.

<!--## OpenMP -->

OpenMP\ [@dagum1998openmp] exists as one of the most widely-used tools in high-performance computing, in-part because of its high-level directive-based approach and broad availability. While OpenMP has traditionally been used to generate multi-threaded code on CPU devices, the recent addition of offloading directives in the OpenMP 4.X+ standards has extended OpenMP to also support accelerator devices, primarily GPUs. Similarly to OpenACC, the OpenMP offloading directives provide a high-level alternative to low-level offloading models like OpenCL and CUDA, and provide existing OpenMP programmers a familiar entrance to accelerator computing.

<!-- Survey -->
The confidentiality of many supercomputer-scale scientific codes means it is unknown what percentage of kernels are developed in CUDA, OpenCL, OpenMP or OpenACC by the scientific community.
If we assume the open-source community adoption of accelerator programming frameworks reflects their popularity in the scientific HPC community, a survey of GitHub can help indicate their relative adoption rates.
As of January 2020, the number of github repositories including CUDA in the repository title was 18k; 8k for OpenCL, 5k for OpenMP 5K, and fewer than 400 for OpenACC.
If we compare the lines of code (Github presented metric) as a measure of language popularity, github classified 8M lines of CUDA code, 2M lines of OpenCL, 2M lines of OpenMP, and 124K lines of OpenACC.
Of the newer frameworks, SYCL is either in the title or description of 144 repositories, and github classified 402k lines of code as SYCL.
At the time of writing, OneAPI is less than a year old, and there are already 56 repositories and 4k lines of code related to it.
This survey was performed by searching for "CUDA", "OPENCL", "OPENMP", "OPENACC", "SYCL" and "ONEAPI" in GitHub.\footnote{\url{www.github.com}}
We are unable to be more precise around actual repositories using accelerator programming frameworks because OpenCL, OpenMP and OpenACC are not tracked as individual languages by GitHub.
However CUDA is listed as a language with ~5.9k repositories listed.
Based on these results, we suspect that OpenCL may not be positioned to win the race to adoption.

Appropriate support of translator tools will allow us to ensure OpenCL is utilized -- as a back-end runtime supported on most devices.
Mapping back to a common OpenCL runtime is an obvious choice, as it supports the greatest range of accelerator devices and multiple front-end languages. The idea of a common back-end representation like OpenCL potentially avoids fragmentations and repeated implementation as systems are updated and accelerators replaced, and having efficient tools to enable this mapping OpenCL is paramount. In this work, we use AIWC to evaluate the similarities and differences between outputs of translation tools on functionally equivalent kernel codes. We show that AIWC can be used to guide the understanding of the tools mapping between high-level source languages and OpenCL, and potentially guide improvements to these tools.


# Related Work{#sec:related}

<!--## AIWC-->

The Architecture-Independent Workload Characterization (AIWC) [@opendwarfs2017base] tool describes a workload in terms of statistics around the programs fundamental behaviour.
For instance, summary statistics on the arithmetic intensity, branching behaviour and types of parallelism and the granularity of parallelism expressed within the code.
It operates as a plugin within the Oclgrind [@price:15] LLVM OpenCL device simulator -- namely it simulates an abstract OpenCL device and processes each work-item, it is lossless, deterministic and slower than executing on real accelerator hardware.
During execution the AIWC plugin stores traces around behaviour that is representative of the workload while being removed from any phenomena that would impact the performance on actual hardware.
These traces are evaluated at the end of each kernel run to compute the characterizing statistics.
The listings of these statistics and how they are computed is available in associated literature [@aiwc2018].
The collected metrics have shown to accurately represent the codes characteristics and have shown their suitability in a predictive methodology where the summary statistics were (the only arguments) provided to perform precise execution time predictions over a range of accelerator devices [@johnston2018opencl].

The change in these metrics offer insights around optimization of a code for accelerators by presenting interesting summaries for the developer to consider.
Unfortunately, Oclgrind -- and thus also AIWC -- only support the OpenCL programming language, utilizing translator tools to migrate codes written in other languages into OpenCL will increase the impact of AIWC.

<!--##OpenARC-->

The Open Accelerator Research Compiler (OpenARC)\ [@lee2014openarc] has been developed as a research-oriented OpenACC and OpenMP compiler. OpenARC performs source-to-source translations and code transformations to generate low-level device-optimized code, like CUDA or OpenCL, specific to a targeted device. OpenARC's primary strength is it's ability to enable rapid prototyping of novel ideas, features, and API extensions for emerging technologies.

In this work, we leverage OpenARC's OpenACC to OpenCL and OpenMP to OpenCL translations and use the output with AIWC to characterize the workloads resultant translation. This integration allows us to extend AIWC to characterize high-level codes written with OpenACC and OpenMP. 
<!-- We also leverage an OpenARC-related project, CCAMP\ [@lambert2018heteropar], to perform OpenMP to OpenACC translation. Additionaly, becuase OpenMP offload versions of the Rodinia benchmarks were specifically developed for CPU execution, we use CCAMP's OpenMP optimization pass to generate more GPU friendly OpenMP code for a closer comparisoin with the OpenCL and CUDA counterparts.
-->

<!--##Coriander-->

<!--
At first glance we may be hopeful that AMD's HIP could be used for all CUDA to OpenCL backend translations, however, sadly, it does not use OpenCL as a back-end, instead choosing to use LLVM to generate kernels for the HSA Runtime and Direct-To-ISA skipping intermediate layers such as PTX, HSAIL, or SPIR-V.
It is unknown why this decision was made and by skipping SPIR we are unable to perform the analysis with AIWC over the output since it skips any potential abstract "ideal"/"uniform" device, useful to checking errors, validating memory accesses and performing workload characterization that AIWC and Oclgrind provides.-->
<!--This seems to be partly to avoid the latency associated with standards-body working groups.-->
<!--see https://github.com/ROCm-Developer-Tools/HIP/issues/90-->
The Coriander tool has the functionality of translating CUDA to OpenCL codes.
It achieves compiling the device-side (kernel) code into OpenCL C and by providing a compiler for host-side code, including memory allocation, copy, streams and kernel launches.
Unlike OpenARC it skips source-to-source level translation and instead produces LLVM-IR/SPIR directly.
We use Coriander to translate CUDA codes into OpenCL so we can evaluate the similarities in functionality of benchmarks with AIWC.

# Methodology{#sec:methodology}

AIWC metrics were selected to be architecture independent, it is a reasonable assumption that these metrics should also be language independent.
The methodology to verify this assumption is outline in the following.
Given a functionally identical application but implemented in OpenCL, CUDA, OpenMP and OpenACC, we utilise contemporary translation tools to generate AIWC compatible OpenCL codes, then generate AIWC metrics, and finally compare the AIWC feature-spaces of different language implementations against features from the baseline OpenCL version.
Because AIWC analysis operates directly at the SPIR-V/LLVM-IR level, we utilize translation tools to lower the input languages to the desired abstraction level.
Coriander was used to generate LLVM IR from CUDA input, while OpenARC was used for both OpenMP to OpenCL and OpenACC to OpenCL translation.
An identical version of clang and LLVM (3.9.0) is used to lower the output OpenCL to SPIR from all tools.

\begin{figure*}
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{static-figures/translation-workflow}
    \caption{Workflow of using translators and compilers to interoperate with AIWC.}
    \label{fig:translation-workflow}
\end{figure*}

Figure\ \ref{fig:translation-workflow} presents a summary of the workflow and the various representations generated to interoperate between translators, compilers and AIWC.
This shows how different source implemenations of the same algorithm can generate equivilent workload characterization metrics.
The entire workflow is composed of several stages and representations -- broadly progressing from source code written in various languages, computational intensive regions are translated into OpenCL kernels, compiler with Clang into SPIR, executed on the Oclgrind OpenCL device simulator with the AIWC plugin, AIWC then presents and stores these metrics as a set of features describing the characteristics of the code.
OpenCL can skip the translation stage and kernel representation since the kernel is already presented in OpenCL-C.
OpenARC is used to perform source-to-source translation from OpenACC and OpenMP to OpenCL-C kernels.
Note, coriander does not perform source-to-source translation effectively skipping the kernel representation and compilation stages, it still uses the same version of Clang (from LLVM 3.9.0) to produce the SPIR however this is used from within the tool effectively using clang behind-the-scenes for the compilation stage however the details are hidden from the user and are thus omitted in the diagram.
Our hypothesis is that these characteristics should be largely independent of language used to implement it, although it is expected that different compiler optimizations and translation strategies will subtly change the metrics.
Part of the goal of this paper is to examine the magnitudes of change imposed by language, compiler and translator.
With the similarities between metrics despite the original implementation can be used to evaluate the similarities of application and potential deficiencies in specific compilers.

We selected the Gaussian Elimination application from the Rodinia Benchmark Suite\ [@che2009rodinia] for our evaluation.
By design Rodinia applications are targeted toward accelerator-based systems, and many of the applications in the benchmark suite are represented in multiple programming models, including CUDA, OpenCL, and OpenMP. 
Furthermore, additional OpenMP and OpenACC implementations of various Rodinia applications have been developed by open source extension projects\ [@pathscale], which we utilize in our evaluation.
All implementations of Gaussian Elimination have been divided into two discrete computationally intensive regions/kernels -- known as `Fan1` and `Fan2`.
The former calculates the multiplier matrix while `Fan2` modifies the matrix A into the Lower-Upper Decomposition.
For brevity we only consider `Fan1` in this paper, however both kernels and results are available in the Jupyter artefact.\todo[inline ]{reference artefact}

The translation was largely automatic using both tools to convert between languages.
OpenARC doesn't support C++ programs, thus, some benchmarks we examined had to be converted to ANSI C89, and our biggest pain was with user defined `struct`'s needing to be explicitly mentioned when used.
Coriander lacks support of `cudaMemcpyToSymbol` function calls and required manually replacing to `cudaMemcpy`, similarly, deprecated calls in the code-base to ``cudaThreadSynchronize`` also required replacing with ``cudaDeviceSynchronize``.
The greatest effort in using these tools was in setting them up in the first place, Coriander is selective in versions of LLVM supported, while using both Oclgrind with Coriander raises an interesting LLVM issue.
Essentially multiple libraries that are using LLVM, which has some static initialization functions to register passes, end up breaking if they're called multiple times from the same process.
To solve this issue we build and link all tools (AIWC and the translators) against a shared version of LLVM.
We provide a Docker artefact to alleviate this pain for future users.\footnote{\url{https://github.com/ANU-HPC/coriander-and-oclgrind}}

<!--
# Manual Modifications

## OpenARC 
Source code changes include C++ programs are unsupported as input programs, as such we need to change the `bfs` application extension.
Most of the translation was autonomous, only one explicit typecast for a user defined struct needed to be clarifed use 'struct' keyword to refer to the type.
Use of the preprocessor also doesn't work within OpenARC thus `TRANSFER_GRAPH_NODE` which was `typedef`ed to 1 was explicitly replaced.
<!--
TODO: summarise 
[WARNING] the current OpenARC implementation assumes that input programs follow ANSI C standard (a.k.a C89), which does not allow mixed declarations and code. However, the following procedures have mixed declarations. Please change the procedures such that all delaration statements comes before any expression statements; otherwise, incorrect translation may occur!

* Steps taken to perform code translation from openacc to opencl kernel and wrapper


# Coriander
Use of Coriander was largely autonomous except it lacks support for `cudaMemcpyToSymbol` function calls.

Deprecated calls in the code-base to ``cudaThreadSynchronize`` also required replacing with ``cudaDeviceSynchronize``.
As such, the translation effort was almost entirely focused on replacing these operations with .
Manually replacing certain includes -- for instance `<math.h>` to `<cmath>` -- were needed for the translation effort since Coriander is tied to LLVM 3.9 and is hard-coded to only support C++11.

* Coriander and AIWC were required to both be statically linked against the same version of LLVM due to an error which occurs when two seperate instances of LLVM are registered into the same vtable. **do I mean vtable?**
error "'phi-node-folding-threshold' registered more than once"
These changes have been provided in as an artefact with Docker incase you wish to try for yourself \footnote{\url{https://github.com/ANU-HPC/coriander-and-oclgrind}}
Also many of the CUDA codes would crash during the translation to OpenCL -- thus, only a small subset of the Rodinia Benchmark suite are presented, nonetheless this work forms a proof-of-concept and these issues within Coriander can be fixed.

Source-to-source translation tools:
cu2cl progress on CUDA rodinia bfs `/rodinia/cuda/bfs`:
/cu2cl-build/cu2cl-build/cu2cl-tool bfs.cu ./kernel.cu  -- -I./ 
Results in `<command line>:7:10: fatal error: 'cuda_runtime.h' file not found`
-->

We built the OpenMP version of Gaussian Elimination -- with 4.0 accelerator directives -- based on the OpenACC version.

Adding AIWC into this work-flow had the surprising benefit of finding inconsistencies already present in the Rodinia Benchmark Suite.
We found the existing implementations to lack a perfect mapping between versions, in particular our work (guided by AIWC analysis) modified the partitioning of work to ensure an equivalent division of work is allocated between versions -- allowing an apples-to-apples comparison of languages performing identical benchmark tasks.

The initial CUDA implementation varied in the amount of parallelism compared to OpenCL.
The `Block` size was explicitly set to the `MAXBLOCKSIZE` (512 threads), our change: `block_size = (Size % MAXBLOCKSIZE == 0) ? MAXBLOCKSIZE : Size;` states that if we have smaller work to do than the max block size, just run 1 block of that size, which mirrors the way OpenCL expresses parallelism of this benchmark -- i.e. the `global workgroup size` is the total number of threads to execute run in teams of `local workgroup size`.
Thus, the CUDA implementation went from `512` workitems being invoked (where only 4 of them did any meaningful work) to `4` workitems being run.
To this end, it was adjusted to more closely mirror the behaviour of the OpenCL version offered in the benchmark.


OpenARC uses `workers` and `gangs` variables to express parallelism in the OpenACC to OpenCL setting.
We specified the following variables to mirror functionality of the CUDA and OpenCL versions.
The OpenACC pragmas where modified to explicitly use the `workers` and `gangs` variables<!--: from `#pragma acc parallel loop present(m,a)` to `#pragma acc kernels loop independent gang(gangs) worker(workers)`.-->,
`MAXBLOCKSIZE` was added and set to be 512 as in the other versions. <!--
`gangs = (Size % MAXBLOCKSIZE == 0) ? MAXBLOCKSIZE : Size` is set to be analagous to `block_size = (Size % MAXBLOCKSIZE == 0) ? MAXBLOCKSIZE : Size` which we added to the CUDA version.
Similarly, `workers = (Size/gangs) + (!(Size%gangs)? 0:1)` is now logically equivalent to the other versions with `grid_size = (Size/block_size) + (!(Size%block_size)? 0:1)`.-->

In OpenMP, 4 threads are explictly requested by setting the `OMP_NUM_THREADS=4` environment variable at runtime.
The code is analogous to OpenACC except for `#pragma` notation; `workers` are replaced by `threads` and `gangs` with `teams`.
The kernel source of each of the four implementations is listed in Table \ref{lst:source-code} while the full source-code is available in the associated artefact. \todo[inline]{Add url once this is pushed to github}


<!-- %use a temporary counter for sublists -- so keep a backup of the old one then  change it's styling from arabic to roman -->
\newcounter{mainlisting}
\setcounter{mainlisting}{\value{lstlisting}}
\setcounter{lstlisting}{0}

\renewcommand{\thelstlisting}{\roman{lstlisting}}
\renewcommand{\lstlistingname}{}
\begin{figure*}[htp]
\begin{minipage}[t]{\figcolumnwidth}
\begin{lstlisting}[caption=OpenCL,frame=tlrb,language=c,label=lst:source-opencl]
__kernel void Fan1(__global float *m, __global float *a, const int size, const int t)
{
    int gid = get_local_id(0) + get_group_id(0) * get_local_size(0);

    if (gid < size-1-t) {
        m[size*(gid+t+1)+t] = a[size*(gid+t+1)+t] / a[size*t+t]; 
    }
}
\end{lstlisting}
\end{minipage}\hskip\skipper\relax
\begin{minipage}[t]{\figcolumnwidth}
\begin{lstlisting}[caption=CUDA,frame=tlrb,language=c,label=lst:source-cuda]
__global__ void Fan1(float *m, float *a, int size, int t)
{
    int gid = threadIdx.x + blockIdx.x * blockDim.x;

    if(gid < size-1-t){
        m[size*(gid+t+1)+t] = a[size*(gid+t+1)+t] / a[size*t+t];
    }
}
\end{lstlisting}
\end{minipage}
\vskip-1em\hskip\skipper\relax
\begin{minipage}[t]{\figcolumnwidth}
\begin{lstlisting}[caption=OpenACC,frame=tlrb,language=c,label=lst:source-openacc]
void Fan1(float *m, float *a, int size, int t)
{   
    int i;
    #pragma acc kernels loop independent gang(fan1_gangs) worker(fan1_workers)

    for (i=0; i < size-1-t; i++)
        m[size*(i+t+1)+t] = a[size*(i+t+1)+t] / a[size*t+t];
}
\end{lstlisting}
\end{minipage}\hskip\skipper\relax
\begin{minipage}[t]{\figcolumnwidth}
\begin{lstlisting}[caption=OpenMP,frame=tlrb,language=c,label=lst:source-openmp]
void Fan1(float *m, float *a, int size, int t)
{   
    int i;
    #pragma omp target teams distribute parallel for num_teams(fan1_teams) num_threads(fan1_threads)
    for (i=0; i < size-1-t; i++)
        m[size*(i+t+1)+t] = a[size*(i+t+1)+t] / a[size*t+t];
}
\end{lstlisting}
\end{minipage}
\setcounter{lstlisting}{\value{mainlisting}}
\renewcommand{\thelstlisting}{\arabic{lstlisting}}
\renewcommand{\lstlistingname}{Listing}
\captionof{lstlisting}{All source code implementations of the Fan1 kernel separated by language.}
\label{lst:source-code}
\end{figure*}



# Results {#sec:results}


\begin{figure*}
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{codes/figures/fan1_absolute}
    \caption{Absolute difference in AIWC metrics between each translated Fan1 kernel implementation.}
    \label{fig:fan1-absolute}
\end{figure*}


The comparison of AIWC metrics of the Gaussian Elimination `Fan1` kernel are presented in Figure\ \ref{fig:fan1-absolute}.
Metrics (along the x-axis) have been grouped by category and is indicated by colour.
These categories outline the overall type of characteristic being measured by each metric.
The blue metrics (Opcode and Total Instruction Count) show the "Compute" category (which denote the amount of work to be done per thread and the diversity of the instruction sets required), metrics in green present "Parallelism" type metrics (these metrics are broadly around number of threads available in the workload, the amount of independence between threads and whether vectorization/SIMD is appropriate), "Memory" are presented in beige (and are included to collect the spread, proximity and raw number of memory addresses accessed), while purple metrics indicate "Control" (the predictability of branching during control flow of the workload).
A full list and description of these metrics is available [@johnston2019thesis] but for brevity is not further discussed in this paper.
The y-axis presents the absolute count of each AIWC metric.
The bars have been coloured according to Implementation (as shown in the legend) with CUDA in green, OpenACC in blue, OpenCL in tan and OpenMP in grey.
Each metric has the four implementations grouped together, thus Figure\ \ref{fig:fan1-absolute} gives a visual inspection of the feature-space comparison of each metric between all implementations.
It's expected that OpenCL should be the lowest count -- or the lowest overhead -- of all the implemenations regardless of metric, since it serves as the baseline; a compiler doing source-to-source translations would have to be doing additional optimizations to result in lower counts than the OpenCL baseline.


Figure\ \ref{fig:fan1-relative-difference} shows the same comparison of Fan1 implementations but with normalization against the baseline OpenCL counts, and is done to show the relative difference between each implementation -- allowing a closer inspection of the differences.
A flat-line at 0% is ideal since it shows no difference between metrics captured by AIWC, a perfect translation between implementations results in the same instructions being executed, operating on the same sequence of locations in memory, under the same degree of parallelism and identical AIWC metrics will ensue.
In other words, if the applications workload characteristics are identical between languages the translator is doing an excellent job in preserving the structure (in terms of memory accesses, parallelism and compute work) of the code regardless of language.
The implementations have been separated by colour and grouped into metrics for contrast.
Firstly, the Opcode diversity metric is the same between all implementations however the number of instructions executed differ -- the CUDA translation has 24% more instructions than OpenCL, while OpenACC and OpenMP increase this count by 37%.
To understand the reason, we must examine the translated kernels, generated SPIR and the associated traces of each implementation, these are <!--presented in Listings \ref{lst:kernel-opencl-vs-openmp-and-openacc}, \ref{lst:spir-opencl-vs-cuda} and \ref{lst:trace} respectively, and--> discussed in [Sections @sec:kernel-representation][, @sec:intermediate-representation] [and @sec:trace-analysis] respectively.
We see all "Memory" (beige) metrics (on the x-axis) do not indicate any difference of any implementations against the OpenCL case -- this is good as it ensures that all the same frequency of memory accesses, the type (whether a read or write), the locations and order of memory accesses are preserved and are equivalent in all implementations, and shows an indistinguishable amount of work has occurred.

The "Total Unique Branch Instructions" and "90% Branch Instructions" are doubled in both the OpenACC and OpenMP versions compared to OpenCL and CUDA.
This is because of the absolute doubling in the number of branch instructions the reason becomes apparent when considering the OpenARC generated OpenCL kernels and is discussed during the remainder of this Section.

<!--
\begin{figure*}
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{codes/figures/fan1_relative}
    \caption{Relative AIWC metrics between each translated implementation of the Fan1 kernel against the baseline OpenCL.}
    \label{fig:fan1-relative}
\end{figure*}
-->

\begin{figure*}
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{codes/figures/fan1_relative_difference}
    \caption{Relative difference in AIWC metrics between each translated Fan1 kernel implementation against the baseline OpenCL.}
    \label{fig:fan1-relative-difference}
\end{figure*}

We see no causes where the compiler improves beyond the initial OpenCL baseline.

## Kernel Representation {#sec:kernel-representation}

Listing\ \ref{lst:kernel-opencl-vs-openmp-and-openacc} presents the OpenCL kernels generated in the Kernel Representation stage. 
The workflow from Figure \ref{fig:translation-workflow} shows how the mix of translators interoperate with AIWC, and justifys why CUDA and OpenCL implementations are excluded from this comparison.
Namely, no translation is needed for the OpenCL implementation, while Coriander operating on the CUDA implementation does not generate any kernel representation form and only offers an intermediate representation -- which are discussed in [Section @sec:intermediate-representation].
Of the two translated kernels presented in Listing\ \ref{lst:kernel-opencl-vs-openmp-and-openacc}-\ref{lst:kernel-openacc} and \ref{lst:kernel-opencl-vs-openmp-and-openacc}-\ref{lst:kernel-openmp} can be compared directly to the hand-coded OpenCL kernel presented in Listing \ref{lst:source-code}-\ref{lst:source-opencl} -- they are the translated OpenARC output of OpenACC and OpenMP (from \ref{lst:source-code}-\ref{lst:source-openacc} and \ref{lst:source-code}-\ref{lst:source-openmp}) respectively.
We see the pragmas are preserved in the translated output regardless of whether OpenACC or OpenMP are used, however the OpenMP pragma is expressed in terms of OpenACC -- the number of threads and number of teams are rewritten as workers and gangs -- this is due to an intermediate step in OpenARC which converts OpenMP into OpenACC so it can directly use the OpenACC to OpenCL functionality.
Regarding generated OpenCL kernels, both versions are equivilent, sharing the same logic (identical instructions at the same line numbers). Both have the same number of lines in the generated kernels -- although the lines in the OpenMP based version are longer because of longer variable names.

When compared to the OpenCL hand-coded version shown in Listing\ \ref{lst:source-code}-\ref{lst:source-opencl}, both generated kernels have a fundamental difference in structure.
There is the same check (in the form of an `if`-statement) to ensure work isn't occuring beyond the defined global boundary -- expressed as global work size in OpenCL.
However, there is an added `for`-loop than exists in the OpenCL baseline (Listing \ref{lst:source-code}-\ref{lst:source-opencl}).OpenARC expresses all pragma based acceleration as using both local and global workgroups -- this makes sense as many kernels use local workgroups to utilise shared memory and ensure good memory access patterns (in the form of cache reuse on many hardware architectures) -- but the Fan1 base-line kernel doesn't.
This artifact of translation explains many of the differences in the AIWC metrics when comparing the OpenACC and OpenMP to OpenCL and is discussed further in both the Intermediate-Representation analysis, in [Section @sec:intermediate-representation], and trace analysis, in [Section @sec:trace-analysis].

\setcounter{mainlisting}{\value{lstlisting}}
\setcounter{lstlisting}{0}
\renewcommand{\thelstlisting}{\roman{lstlisting}}
\renewcommand{\lstlistingname}{}
\begin{figure*}[htp]
\centering
%\begin{minipage}[t]{\columnwidth}
%\centering
%\lstinputlisting[language=c,caption=OpenCL,frame=tlrb,label=lst:kernel-opencl]{codes/data/fan1_kernel_opencl.cl}
%\end{minipage}
\hskip\skipper\relax
\begin{minipage}[t]{\figcolumnwidth}
\centering
\lstinputlisting[language=c,caption=OpenACC,frame=tlrb,label=lst:kernel-openacc]{codes/data/fan1_kernel_openacc.cl}
\end{minipage}\hskip\skipper\relax
\begin{minipage}[t]{\figcolumnwidth}
\centering
\lstinputlisting[language=c,caption=OpenMP,frame=tlrb,label=lst:kernel-openmp]{codes/data/fan1_kernel_openmp.cl}
\end{minipage}
\setcounter{lstlisting}{\value{mainlisting}}
\renewcommand{\thelstlisting}{\arabic{lstlisting}}
\renewcommand{\lstlistingname}{Listing}
\captionof{lstlisting}{OpenCL kernel representation comparison to translator generated OpenACC and OpenMP kernels of Fan1.}
\label{lst:kernel-opencl-vs-openmp-and-openacc}
\end{figure*}



## Intermediate-Representation {#sec:intermediate-representation}

\setcounter{mainlisting}{\value{lstlisting}}
\setcounter{lstlisting}{0}
\renewcommand{\thelstlisting}{\roman{lstlisting}}
\renewcommand{\lstlistingname}{}
\begin{figure*}[htp]
\centering
\begin{minipage}[t]{\figcolumnwidth}
\centering
\lstinputlisting[language=llvm,style=nasm,caption=OpenCL,frame=tlrb,label=lst:spir-opencl]{codes/data/opencl_fan1_kernel.ll}
\end{minipage}\hskip\bigskipper\relax
\begin{minipage}[t]{\figcolumnwidth}
\centering
\lstinputlisting[language=llvm,style=nasm,caption=CUDA,frame=tlrb,label=lst:spir-cuda]{codes/data/cuda_fan1_kernel.ll}
\end{minipage}
\setcounter{lstlisting}{\value{mainlisting}}
\renewcommand{\thelstlisting}{\arabic{lstlisting}}
\renewcommand{\lstlistingname}{Listing}
\captionof{lstlisting}{OpenCL compared to the CUDA implementations generated LLVM-IR/SPIR of the Fan1 kernel.}
\label{lst:spir-opencl-vs-cuda}
\end{figure*}

\setcounter{mainlisting}{\value{lstlisting}}
\setcounter{lstlisting}{0}
\renewcommand{\thelstlisting}{\roman{lstlisting}}
\renewcommand{\lstlistingname}{}
\begin{figure*}[htp]
\centering
\begin{minipage}[t]{\figcolumnwidth}
\centering
\lstinputlisting[language=llvm,style=nasm,caption=OpenCL,frame=tlrb,label=lst:spir-opencl]{codes/data/opencl_fan1_kernel.ll}
\end{minipage}\hskip\bigskipper\relax
\begin{minipage}[t]{\figcolumnwidth}
\centering
\lstinputlisting[language=llvm,style=nasm,caption=OpenACC and OpenMP,frame=tlrb,label=lst:spir-openacc-and-openmp]{codes/data/openacc_fan1_kernel.ll}
\end{minipage}
\setcounter{lstlisting}{\value{mainlisting}}
\renewcommand{\thelstlisting}{\arabic{lstlisting}}
\renewcommand{\lstlistingname}{Listing}
\captionof{lstlisting}{OpenCL compared to the OpenMP and OpenACC implementations generated LLVM-IR/SPIR of the Fan1 kernel.}
\label{lst:spir-opencl-vs-openacc-and-openmp}
\end{figure*}

A comparison between generated LLVM/SPIR is presented in Listings\ \ref{lst:spir-opencl-vs-cuda} and \ref{lst:spir-opencl-vs-openacc-and-openmp}.
Both identify differences in SPIR between Coriander (for CUDA implementations) and OpenARC (OpenACC and OpenMP) compiler outputs against the OpenCL based native version.
The similarities between OpenMP and OpenACC implementations of the Fan1 kernel -- along with using the same compiler/translator toolchain -- means that the generated SPIR are identical and thus consolidated into a single Listing\ (\ref{lst:spir-opencl-vs-openacc-and-openmp}-\ref{lst:spir-openacc-and-openmp}).

## Trace Analysis {#sec:trace-analysis}

To examine these differences in actual execution based on the LLVM-IR codes we added the printing of the name of each executed instruction thereby giving a trace of each implementation.
This was achieved by adding:

````
if(workItem->getGlobalID()[0]==0){
   printf("%s\n",opcode_name.c_str());
}
````

to the function `instructionExecuted` to AIWC (in `src/plugins/WorkloadCharacterisation.cpp`) which is triggered as a callback when the Oclgrind simulator executes each instruction.
Since oclgrind is a multi-threaded simulator -- to the extent that each OpenCL workitem is run on a separate pthread -- we only print the log if it occurs on the first thread.
These traces were then collected from each of the implementations.

\setcounter{mainlisting}{\value{lstlisting}}
\setcounter{lstlisting}{0}
\renewcommand{\thelstlisting}{\roman{lstlisting}}
\renewcommand{\lstlistingname}{}
\begin{figure*}[htp]
\centering
\begin{minipage}[t]{\qcolumnwidth}
\centering
\begin{lstlisting}[caption=OpenCL,frame=tlrb,language=c,label=lst:trace-opencl]


call


call

call

mul
add
<@\textcolor{blue}{trunc}@>
add
sub
icmp
br


add

add
mul

sext
<@\textcolor{blue}{getelementptr}@>
sext

getelementptr
load


mul

sext
getelementptr
getelementptr
load
fdiv
getelementptr
getelementptr
store







br
ret

\end{lstlisting}
\end{minipage}
\hskip\skipper\relax
\begin{minipage}[t]{\qcolumnwidth}
\centering
\begin{lstlisting}[caption=CUDA,frame=tlrb,language=c,label=lst:trace-cuda]
<@\textcolor{red}{getelementptr}@>
<@\textcolor{red}{bitcast}@>
call
<@\textcolor{red}{trunc}@>

call
<@\textcolor{red}{trunc}@>
call
<@\textcolor{blue}{trunc}@>
mul
add

add
sub
icmp
br
<@\textcolor{red}{getelementptr}@>
<@\textcolor{red}{bitcast}@>
add

add
mul

sext

sext
<@\textcolor{blue}{getelementptr}@>
getelementptr
load


mul

sext
getelementptr
getelementptr
load
fdiv
getelementptr
getelementptr
store







br
ret

\end{lstlisting}
\end{minipage}
\hskip\skipper\relax
\begin{minipage}[t]{\qcolumnwidth}
\centering
\begin{lstlisting}[caption=OpenACC,frame=tlrb,language=c,label=lst:trace-openacc]


call
<@\textcolor{red}{trunc}@>
<@\textcolor{red}{sext}@>
call

<@\textcolor{olive}{sext}@>

mul




icmp
br


add
<@\textcolor{red}{sub}@>
add
mul
<@\textcolor{red}{add}@>
sext
getelementptr
<@\textcolor{olive}{br}@>

<@\textcolor{olive}{phi}@>
<@\textcolor{olive}{icmp}@>
<@\textcolor{red}{br}@>
<@\textcolor{red}{add}@>
mul
<@\textcolor{red}{add}@>
sext
getelementptr
<@\textcolor{olive}{load}@>
load
fdiv
getelementptr

store
<@\textcolor{red}{zext}@>
<@\textcolor{red}{add}@>
<@\textcolor{red}{trunc}@>
<@\textcolor{red}{br}@>
<@\textcolor{red}{phi}@>
<@\textcolor{red}{icmp}@>
<@\textcolor{red}{br}@>
br
ret

\end{lstlisting}
\end{minipage}
\hskip\skipper\relax
\begin{minipage}[t]{\qcolumnwidth}
\centering
\begin{lstlisting}[caption=OpenMP,frame=tlrb,language=c,label=lst:trace-openmp]


call
<@\textcolor{red}{trunc}@>
<@\textcolor{red}{sext}@>
call

<@\textcolor{olive}{sext}@>

mul




icmp
br


add
<@\textcolor{red}{sub}@>
add
mul
<@\textcolor{red}{add}@>
sext
getelementptr
<@\textcolor{olive}{br}@>

<@\textcolor{olive}{phi}@>
<@\textcolor{olive}{icmp}@>
<@\textcolor{red}{br}@>
<@\textcolor{red}{add}@>
mul
<@\textcolor{red}{add}@>
sext
getelementptr
<@\textcolor{olive}{load}@>
load
fdiv
getelementptr

store
<@\textcolor{red}{zext}@>
<@\textcolor{red}{add}@>
<@\textcolor{red}{trunc}@>
<@\textcolor{red}{br}@>
<@\textcolor{red}{phi}@>
<@\textcolor{red}{icmp}@>
<@\textcolor{red}{br}@>
br
ret

\end{lstlisting}
\end{minipage}
\setcounter{lstlisting}{\value{mainlisting}}
\renewcommand{\thelstlisting}{\arabic{lstlisting}}
\renewcommand{\lstlistingname}{Listing}
\captionof{lstlisting}{Trace of instructions executed by thread 0 of Fan1 kernel for each of the language implementations.}
\label{lst:trace}
\end{figure*}

The differences between traces are shown in Listing\ \ref{lst:trace}.
The OpenCL trace is shown in Listing \ref{lst:trace}-\ref{lst:trace-opencl} and presents the baseline progression of instructions, \ref{lst:trace-cuda} is the CUDA trace, OpenACC in \ref{lst:trace-openacc} and OpenMP in \ref{lst:trace-openmp}.
Each trace should be read as the LLVM instruction executed over time as we proceed down the Listing.
Blank lines have been inserted to align common instructions in the trace between implementations, this is to present the clearest difference between traces.
Instructions of interest have also been coloured -- red indicates added instructions no apparent in the baseline OpenCL trace, blue instructions show a reordering of instructions between traces and olive shows substitution (or deviation) of instructions.
The CUDA trace shows that each \todo[inline]{tie in instructions added with each memory lookup from the SPIR}.
The OpenACC trace has no instruction reordering but has instructions added to componsate for the different control flow (looping) to support the workitems in a workgroup logic -- as was described in Section \ref{sec:intermediate-representation}.
There is no difference in traces between OpenMP and OpenACC traces because it uses the same OpenARC compiler toolchain.

<!--
## Fan2

Thus we can use example to illustrate how AIWC metrics highlight discrepencies between languages and implementations and how it can be used to guide sourcecode changes.
Two separate loops in the `Fan2` function were consolidated into one, to mirror how the task is performed in the OpenCL and CUDA implementations of the algorithm.
-->

# Conclusions and Future Work{#sec:conclusion}


This work extends the applicabilty of AIWC by supporting multiple languages and have demonstrated it's usefulness to evaluate the overhead and complexities of the OpenCL output from two source code translation tools.
We believe this methodology can be boardly more useful in the future development of translators.

Since AIWC metrics are based on an abstract/ideal OpenCL device simulator there are architecture-specific optimizations that may occur when you target the LLVM-IR/SPIR to a specific accelerator however this is expected to be consistant reguardless of the compiler front-end, and the former issue is not a subject for this work.

We will apply the methodology of generating AIWC feature-spaces to other languages, specifically OpenMP and OpenACC -- since this is the typical means of accelerating conventional HPC workloads using many-core CPUs.
The ability to examine the characteristics of these kernels in large code-bases allow optimization work to occur on these kernels, effectively guiding a developers hand to optimize a code by providing strategies to minimise certain AIWC metrics shown to be advantageous to specific accelerators.
Additionally, examining the AIWC features of existing code-bases may facilitate identifying a better accelerator match as they become available.

Thus, this work identifies the potential overheads when translating between functionally identical implementations of kernels written in different languages by examining differences in ther respective AIWC metrics.
We also offer a methodology which uses AIWC over a number of tests kernels, and against an OpenCL implementation as a base-line, is an option to assess the suitability of any changes made to the translator.
This work will assist the improvement of the translation tools on offer, increasing the adoption of SPIR-V and the use of the OpenCL runtime behind-the-scenes, resulting in less fragmentation between software models and languages on contemporary HPC systems.

This paper shows that the visual inspection of AIWC metrics facilitates a high-level (and quick) overview of computational characteristics of kernels, and we have found that how they change has enabled us to compare the execution behaviour of codes in response to different compilers performing translation.
We have seen how source-code modifications in our selected benchmark kernels change these features -- in our instance to more closely resemble an OpenCL baseline.We believe the same methodology will be useful for compiler engineers to evaluate their own translators -- especially with the increasing use of LLVM as a backend, on which AIWC and this approach is based.
This is useful since it is abstracted to an ideal OpenCL device and, as such, is free from micro-architecture and architectural details.
We proprose this methodology will also encourage application developers of scientific codes to take a deeper-dive into their codes, and more generally, our future work will examine how AIWC metrics provide a developer insights around the suitability of the kernel code when initially selecting for, then optimizing on, specific accelerators.

# References
