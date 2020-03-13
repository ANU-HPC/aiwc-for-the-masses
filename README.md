
Architecture-Independent Workload Characterization for OpenMP, OpenACC, Cuda and OpenCL
---------------------------------------------------------------------------------

**Note:** Static Jupyter artefact is available [here](./codes/AIWC-metric-comparison-of-Cuda-OpenACC-and-OpenCL.ipynb)

This artefact uses binder -- automatic cloud hosting of Jupyter workbooks with support for docker. So if you want to avoid all the steps mentioned below, simply click the binder badge.

[![Binder](https://mybinder.org/badge.svg)](https://mybinder.org/v2/gh/BeauJoh/performance-and-code-portable-vectorization-with-opencl/master)

# Installation

This project uses Docker to facilitate reproducibility. As such, it has the following dependencies:

* nvidia-docker2 -- available [here](https://github.com/NVIDIA/nvidia-docker)

# Build

To generate a docker image named artefact, run:

`docker build -t artefact .`

# Run

To start the docker image run:

`docker run --runtime=nvidia -it --mount src=`pwd`,target=/workspace,type=bind -p 8888:8888 --net=host artefact`

And run the codes with:
`cd /codes`

`make`

`make test`

This generates a sample of the runtimes with libscibench and the AIWC metrics

For reproducibility, BeakerX has also been added for replicating results and for the transparency of analysis.
It is lauched by running:

`cd /codes`
`beakerx --allow-root`

from within the container and following the prompts to access it from the website front-end.

*Note* that if this node is accessed from an ssh session local ssh port forwarding is required and is achieved with the following:

`ssh -N -f -L localhost:8888:localhost:8888 <node-name>`

