## An Ubuntu environment configured for building the phd repo.
#FROM nvidia/cuda:9.1-devel-ubuntu16.04
##FROM nvidia/opencl
##FROM ubuntu:16.04
#
#MAINTAINER Beau Johnston <beau.johnston@anu.edu.au>
#
## Disable post-install interactive configuration.
## For example, the package tzdata runs a post-installation prompt to select the
## timezone.
#ENV DEBIAN_FRONTEND noninteractive
#
## Setup the environment.
#ENV HOME /root
#ENV USER docker
#ENV LSB_SRC /libscibench-source
#ENV LSB /libscibench
#ENV LEVELDB_SRC /leveldb-source
#ENV LEVELDB_ROOT /leveldb
#ENV OCLGRIND_SRC /oclgrind-source
#ENV OCLGRIND /oclgrind
#ENV OCLGRIND_BIN /oclgrind/bin/oclgrind
#ENV GIT_LSF /git-lsf
#ENV PREDICTIONS /opencl-predictions-with-aiwc
#ENV EOD /OpenDwarfs
#ENV OCL_INC /opt/khronos/opencl/include
#ENV OCL_LIB /opt/intel/opencl-1.2-6.4.0.25/lib64
#ENV LLVM_SRC_ROOT /downloads/llvm
#ENV LLVM_BUILD_ROOT /downloads/llvm-build
#
## Install essential packages.
#RUN apt-get update
#RUN apt-get install --no-install-recommends -y software-properties-common \
#    ocl-icd-opencl-dev \
#    pkg-config \
#    build-essential \
#    git \
#    make \
#    zlib1g-dev \
#    apt-transport-https \
#    dirmngr \
#    gnupg-curl \
#    gnupg2 \
#    wget
#
## Install cmake -- newer version than with apt
#RUN wget -qO- "https://cmake.org/files/v3.12/cmake-3.12.1-Linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr
#
## Install OpenCL Device Query tool
#RUN git clone https://github.com/BeauJoh/opencl_device_query.git /opencl_device_query
#
## Install LibSciBench
#RUN apt-get install --no-install-recommends -y llvm-3.9 llvm-3.9-dev clang-3.9 libclang-3.9-dev gcc g++
#RUN git clone https://github.com/spcl/liblsb.git $LSB_SRC
#WORKDIR $LSB_SRC
#RUN ./configure --prefix=$LSB
#RUN make
#RUN make install
#
## Install leveldb (optional dependency for OclGrind)
#RUN git clone https://github.com/google/leveldb.git $LEVELDB_SRC
#RUN mkdir $LEVELDB_SRC/build
#WORKDIR $LEVELDB_SRC/build
#RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX=$LEVELDB_ROOT
#RUN make
#RUN make install
#
## Install OclGrind
#RUN git clone https://github.com/BeauJoh/Oclgrind.git $OCLGRIND_SRC
#
#RUN mkdir $OCLGRIND_SRC/build
#WORKDIR $OCLGRIND_SRC/build
#ENV CC clang-3.9
#ENV CXX clang++-3.9
#
#RUN cmake $OCLGRIND_SRC -DUSE_LEVELDB=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLLVM_DIR=/usr/lib/llvm3.9/lib/cmake -DCLANG_ROOT=/usr/lib/clang/3.9.1 -DCMAKE_INSTALL_PREFIX=$OCLGRIND
#
#RUN make
#RUN make install
#
## Install R and model dependencies
#RUN apt-get install --no-install-recommends -y libcurl4-openssl-dev libssl-dev
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
#RUN add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/'
#RUN apt-get update
#RUN apt-get install --no-install-recommends -y r-base libcurl4-openssl-dev libssl-dev r-cran-rcppeigen liblapack-dev libblas-dev libgfortran-5-dev
#RUN Rscript -e "install.packages('devtools',repos = 'http://cran.us.r-project.org');"
#RUN Rscript -e "devtools::install_github('imbs-hl/ranger')"
## Install the git-lsf module
#WORKDIR /downloads
#RUN wget https://github.com/git-lfs/git-lfs/releases/download/v2.5.1/git-lfs-linux-amd64-v2.5.1.tar.gz
#RUN mkdir $GIT_LSF
#RUN tar -xvf git-lfs-linux-amd64-v2.5.1.tar.gz --directory $GIT_LSF
#WORKDIR $GIT_LSF
#RUN ./install.sh
#RUN git lfs install
## Install the R model
#RUN git clone https://github.com/BeauJoh/opencl-predictions-with-aiwc.git $PREDICTIONS
#
## Install beakerx
#RUN apt-get install --no-install-recommends -y python3-pip python3-setuptools python3-dev libreadline-dev libpcre3-dev libbz2-dev liblzma-dev
#RUN pip3 install --upgrade pip
#RUN pip3 install tzlocal rpy2 requests beakerx \
#    && beakerx install
#
## Install R module for beakerx
#RUN Rscript -e "devtools::install_github('IRkernel/IRkernel')"
#RUN Rscript -e "IRkernel::installspec(user = FALSE)"
#RUN Rscript -e "devtools::install_github('tidyverse/magrittr')"
#RUN Rscript -e "devtools::install_github('tidyverse/ggplot2')"
#RUN Rscript -e "devtools::install_github('tidyverse/tidyr')"
#
## Install LetMeKnow
#RUN pip3 install -U 'lmk==0.0.14'
## setup lmk by copying or add .lmkrc to /root/
## is used as: python3 ../opendwarf_grinder.py 2>&1 | lmk -
## or: lmk 'python3 ../opendwarf_grinder.py'
#
## Intel CPU OpenCL
#RUN apt-get update -q && apt-get install --no-install-recommends -yq alien wget clinfo \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#
## Download the Intel OpenCL CPU runtime and convert to .deb packages
#RUN export RUNTIME_URL="http://registrationcenter-download.intel.com/akdlm/irc_nas/9019/opencl_runtime_16.1.1_x64_ubuntu_6.4.0.25.tgz" \
#    && export TAR=$(basename ${RUNTIME_URL}) \
#    && export DIR=$(basename ${RUNTIME_URL} .tgz) \
#    && wget -q ${RUNTIME_URL} \
#    && tar -xf ${TAR} \
#    && for i in ${DIR}/rpm/*.rpm; do alien --to-deb $i; done \
#    && rm -rf ${DIR} ${TAR} \
#    && dpkg -i *.deb \
#    && rm *.deb
#
#RUN mkdir -p /etc/OpenCL/vendors/ \
#    && echo "$OCL_LIB/libintelocl.so" > /etc/OpenCL/vendors/intel.icd
#RUN echo /usr/lib/x86_64-linux-gnu/libnvidia-opencl.so.1 > /etc/OpenCL/vendors/nvidia.icd
#
## Let the system know where the OpenCL library can be found at load time.
#ENV LD_LIBRARY_PATH $OCL_LIB:$LD_LIBRARY_PATH
#
## Install EOD
#RUN apt-get update && apt-get install --no-install-recommends -y autoconf libtool automake
#RUN git clone https://github.com/BeauJoh/OpenDwarfs.git $EOD
#WORKDIR $EOD
#RUN ./autogen.sh
#RUN mkdir build
#WORKDIR $EOD/build
#RUN ../configure --with-libscibench=$LSB
#RUN make
#
##Install PGI community edition compiler
##RUN apt-get install --no-install-recommends -y curl
##WORKDIR /downloads
##RUN curl --user-agent "aiwc" \
##    --referer "http://www.pgroup.com/products/community.htm" --location  \
##    "https://www.pgroup.com/support/downloader.php?file=pgi-community-linux-x64" > pgi.tar.gz 
##RUN tar -xvf pgi.tar.gz \
##    && export PGI_SILENT=true \
##    && export PGI_ACCEPT_EULA=accept \
##    && export PGI_INSTALL_DIR="${HOME}/pgi" \
##    && export PGI_INSTALL_NVIDIA=false \
##    && export PGI_INSTALL_AMD=false \
##    && export PGI_INSTALL_JAVA=false \
##    && export PGI_INSTALL_MPI=false \
##    && export PGI_MPI_GPU_SUPPORT=false \
##    && export PGI_INSTALL_MANAGED=false \
##    && /downloads/install_components/install
##ENV PATH "${PATH}:$/root/pgi/linux86-64-llvm/2018/bin"
##
###Install CU2CL
##RUN git clone https://github.com/vtsynergy/CU2CL.git /cu2cl-build
##WORKDIR /cu2cl-build
##COPY ./codes/cu2cl_build.patch .
##RUN patch < ./cu2cl_build.patch
##RUN export CC=/usr/bin/gcc && export CXX=/usr/bin/g++ && ./install.sh && unset CC && unset CXX
##RUN alias cu2cl-tool=/cu2cl-build/cu2cl-build/cu2cl-tool
#
##Install Rodinia Benchmark Suite
#RUN git clone https://github.com/BeauJoh/rodinia.git /rodinia
#
##Install rocm
##RUN wget -qO - http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key | apt-key add -
##RUN echo 'deb [arch=amd64] http://repo.radeon.com/rocm/apt/debian/ xenial main' | tee /etc/apt/sources.list.d/rocm.list
##RUN apt-get update
##RUN apt-get install --no-install-recommends -y libnuma-dev libunwind-dev rocm-dev
##
###Install hcc2
##WORKDIR /downloads
##RUN wget https://github.com/ROCm-Developer-Tools/hcc2/releases/download/rel_0.5-4/hcc2_0.5-4_amd64.deb 
##RUN dpkg -i hcc2_0.5-4_amd64.deb
##
###Install SPIR generator
##RUN apt-get install --no-install-recommends -y subversion libxml2-dev
##WORKDIR /downloads
##RUN git clone http://llvm.org/git/llvm.git llvm
##WORKDIR /downloads/llvm
##RUN git checkout --track -b release_32 remotes/origin/release_32
##WORKDIR $LLVM_SRC_ROOT/tools
##RUN git clone https://github.com/KhronosGroup/SPIR clang
##WORKDIR $LLVM_SRC_ROOT/tools/clang
##RUN git checkout spir_12
##WORKDIR $LLVM_BUILD_ROOT
##RUN cmake $LLVM_SRC_ROOT && make
##RUN make install
#
##Install cuda-on-cl
#ARG GIT_BRANCH=master
#WORKDIR /coriander
#RUN apt-get update && apt-get install -y --no-install-recommends \
#    cmake cmake-curses-gui git gcc g++ libc6-dev zlib1g-dev \
#    libtinfo-dev \
#    curl ca-certificates build-essential wget xz-utils \
#    clinfo apt-utils\
#    bash-completion
##RUN mkdir /usr/lib/nvidia
##RUN apt-get install -y --no-install-recommends nvidia-opencl-icd-367
#RUN git clone --recursive https://github.com/hughperkins/coriander -b ${GIT_BRANCH}
#RUN cd coriander && \
#    mkdir soft && \
#    cd soft && \
#    wget --progress=dot:giga http://releases.llvm.org/4.0.0/clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz
#RUN cd coriander/soft && \
#    tar -xf clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz && \
#    mv clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-16.04 llvm-4.0
#RUN cd coriander && \
#    mkdir build && \
#    cd build && \
#    cmake .. -DCMAKE_BUILD_TYPE=Debug -DCLANG_HOME=$PWD/../soft/llvm-4.0 && \
#    make -j 4
#RUN cd coriander/build && \
#    make -j 4 tests
#RUN cd coriander/build && \
#    make install
#
##Install clblas
#RUN git clone https://github.com/CNugteren/CLBlast.git /downloads/clblast
#WORKDIR /downloads/clblast/build
#RUN cmake .. && make -j 8 && make install
#
#RUN apt-get install -y --no-install-recommends vim silversearcher-ag
##container environment setup
#SHELL ["/bin/bash", "-c"]
#CMD source ~/coriander/activate && bash
#
#WORKDIR /workspace
#ENV LD_LIBRARY_PATH "${OCLGRIND}/lib:${LSB}/lib:./lib:${LD_LIBRARYPATH}"
#ENV PATH "${PATH}:${OCLGRIND}/bin}"
#
##start beakerx/jupyter by default
##CMD ["beakerx", "--allow-root"]

# An Ubuntu environment configured for building the paper repo.
FROM nvidia/opencl

MAINTAINER Beau Johnston <beau.johnston@anu.edu.au>

ENV DEBIAN_FRONTEND noninteractive

# Setup the environment.
ENV HOME /root
ENV USER docker
ENV LSB_SRC /libscibench-source
ENV LSB /libscibench
ENV LEVELDB_SRC /leveldb-source
ENV LEVELDB_ROOT /leveldb
ENV OCLGRIND_SRC /oclgrind-source
ENV OCLGRIND /oclgrind
ENV OCLGRIND_BIN /oclgrind/bin/oclgrind
ENV GIT_LSF /git-lsf
ENV PREDICTIONS /opencl-predictions-with-aiwc
ENV EOD /OpenDwarfs
ENV OCL_INC /opt/khronos/opencl/include
ENV OCL_LIB /opt/intel/opencl-1.2-6.4.0.25/lib64
ENV LLVM_SRC_ROOT /downloads/llvm
ENV LLVM_BUILD_ROOT /downloads/llvm-build
ENV COCL /coriander/bin/bin/cocl

# Install essential packages.
RUN apt-get update
RUN apt-get install --no-install-recommends -y software-properties-common \
    ocl-icd-opencl-dev \
    pkg-config \
    build-essential \
    git \
    make \
    zlib1g-dev \
    apt-transport-https \
    dirmngr \
    wget \
    gcc \
    g++

# Install cmake -- newer version than with apt
RUN wget -qO- "https://cmake.org/files/v3.12/cmake-3.12.1-Linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr

# Install OpenCL Device Query tool
RUN git clone https://github.com/BeauJoh/opencl_device_query.git /opencl_device_query

#Install Cuda
RUN apt-get update -q && apt-get install --no-install-recommends -yq nvidia-cuda-toolkit

# Install LibSciBench
RUN git clone https://github.com/spcl/liblsb.git $LSB_SRC
WORKDIR $LSB_SRC
RUN ./configure --prefix=$LSB
RUN make
RUN make install

# Install leveldb (optional dependency for OclGrind)
RUN git clone https://github.com/google/leveldb.git $LEVELDB_SRC
RUN mkdir $LEVELDB_SRC/build
WORKDIR $LEVELDB_SRC/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX=$LEVELDB_ROOT
RUN make
RUN make install

# Pull down coriander
WORKDIR /coriander
RUN apt-get update && apt-get install -y --no-install-recommends git gcc g++ libc6-dev zlib1g-dev \
    libtinfo-dev \
    curl ca-certificates build-essential wget xz-utils \
    apt-utils bash-completion
RUN git clone --recursive https://github.com/beaujoh/coriander -b master
RUN cd coriander && \
    mkdir soft

# Install LLVM 3.9.0 -- with dynamic libraries
WORKDIR /coriander/soft
RUN wget http://releases.llvm.org/3.9.0/llvm-3.9.0.src.tar.xz && tar -xf llvm-3.9.0.src.tar.xz
WORKDIR /coriander/soft/llvm-3.9.0.src/tools
RUN wget http://releases.llvm.org/3.9.0/cfe-3.9.0.src.tar.xz && tar -xf cfe-3.9.0.src.tar.xz && mv cfe-3.9.0.src clang
WORKDIR /coriander/soft/llvm-3.9.0.build
RUN cmake -DBUILD_SHARED_LIBS=On -DLLVM_BUILD_LLVM_DYLIB=On -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=/coriander/soft/llvm-3.9.0.bin /coriander/soft/llvm-3.9.0.src
RUN make -j32
RUN make install

##Install coriander
WORKDIR /coriander/build
RUN cmake /coriander/coriander -DCMAKE_BUILD_TYPE=Debug -DCLANG_HOME=/coriander/soft/llvm-3.9.0.bin -DCMAKE_INSTALL_PREFIX=/coriander/bin && make -j 32 && make install
RUN apt-get update && apt-get install -y --no-install-recommends gcc-multilib g++-multilib
RUN wget --directory-prefix=/coriander/bin/include/cocl/ https://raw.githubusercontent.com/llvm-mirror/clang/master/lib/Headers/__clang_cuda_builtin_vars.h
RUN python3 /coriander/bin/bin/cocl_plugins.py install --repo-url https://github.com/hughperkins/coriander-CLBlast.git
RUN mv /coriander/bin/lib/coriander_plugins/* /coriander/bin/lib/
RUN make install

# Install utilities
RUN apt-get install -y --no-install-recommends vim less silversearcher-ag

# Install OclGrind
RUN apt-get install --no-install-recommends -y libreadline-dev
RUN git clone https://github.com/BeauJoh/Oclgrind.git $OCLGRIND_SRC
RUN mkdir $OCLGRIND_SRC/build
WORKDIR $OCLGRIND_SRC/build
ENV CC /coriander/soft/llvm-3.9.0.bin/bin/clang
ENV CXX /coriander/soft/llvm-3.9.0.bin/bin/clang++
RUN cmake $OCLGRIND_SRC -DUSE_LEVELDB=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLLVM_DIR=/coriander/soft/llvm-3.9.0.bin/lib/cmake/llvm -DCLANG_ROOT=/coriander/soft/llvm-3.9.0.bin -DCMAKE_INSTALL_PREFIX=$OCLGRIND -DBUILD_SHARED_LIBS=On
RUN make
RUN make install

#Install Rodinia Benchmark Suite
RUN git clone https://github.com/BeauJoh/rodinia.git /rodinia

# Install R and model dependencies
RUN apt-get install --no-install-recommends -y dirmngr gpg-agent
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
RUN apt-get -y --no-install-recommends update
RUN apt-get -y --no-install-recommends install r-base-dev r-base-core r-recommended
RUN apt-get install -t bionic -y libcurl4-openssl-dev 
RUN apt-get install -t bionic -y libssl-dev
RUN apt-get install -y libxml2-dev libxslt-dev
RUN Rscript -e "install.packages('devtools')"
RUN Rscript -e "devtools::install_github('imbs-hl/ranger')"

# Install beakerx
RUN apt-get update && apt-get install --no-install-recommends -y python3-pip python3-setuptools python3-dev libreadline-dev libpcre3-dev libbz2-dev liblzma-dev r-base
RUN pip3 install --upgrade pip
RUN pip3 install tzlocal rpy2 requests beakerx ipywidgets pandas py4j

# Install R module for beakerx
RUN Rscript -e "devtools::install_github('IRkernel/IRkernel')"\
    && Rscript -e "IRkernel::installspec(user = FALSE)"\
    && Rscript -e "devtools::install_github('cran/RJSONIO')"\
    && Rscript -e "devtools::install_github('r-lib/httr')"\
    && Rscript -e "devtools::install_github('tidyverse/magrittr')"\
    && Rscript -e "devtools::install_github('tidyverse/ggplot2')"\
    && Rscript -e "devtools::install_github('tidyverse/tidyr')"\
    && Rscript -e "devtools::install_github('BeauJoh/fmsb')"\
    && Rscript -e "devtools::install_github('wilkelab/cowplot')"\
    && Rscript -e "devtools::install_github('cran/gridGraphics')"\
    && Rscript -e "devtools::install_github('cran/Metrics')"\
    && Rscript -e "devtools::install_github('cran/latex2exp')"\
    && Rscript -e "devtools::install_github('cran/akima')" \
    && Rscript -e "devtools::install_github('cran/pander')"
RUN beakerx install

# Setup OpenARC
RUN apt-get update && apt-get install -yyq openjdk-8-jre openjdk-8-jdk
ENV OPENARC_ARCH 1
ENV ACC_DEVICE_TYPE RADEON

#Test by default
WORKDIR /workspace/codes
CMD make test && make clean
