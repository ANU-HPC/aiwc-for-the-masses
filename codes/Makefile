
all: gaussian_cuda gaussian_opencl gaussian_hand_opencl gaussian_openacc\
	bfs_cuda bfs_opencl bfs_hand_opencl bfs_openacc

test: test_gaussian test_bfs #test_myocyte #test_heartwall

#all: gaussian bfs #hotspot cfd myocyte heartwall

############
# Gaussian #
############
gaussian: gaussian_cuda gaussian_opencl gaussian_hand_opencl
gaussian_cuda: gaussian_cuda_version/gaussian.cu
	nvcc gaussian_cuda_version/gaussian.cu -o gaussian_cuda

gaussian_opencl: ./gaussian_cuda_version/gaussian.cu
	${COCL} ./gaussian_cuda_version/gaussian.cu -o gaussian_opencl

#Uses OpenARC to perform source-to-source translation from OpenACC -> OpenCL
OPENARC_ARGS = OPENARCRT=/workspace/codes/OpenARC/openarcrt OPENARC_ARCH=1 ACC_DEVICE_TYPE=RADEON
gaussian_openacc: ./gaussian_openacc_version/gaussian.c
	cd ./gaussian_openacc_version; ${OPENARC_ARGS} ./O2GBuild.script; ${OPENARC_ARGS} make

gaussian_hand_opencl: gaussian_opencl_version/*.cpp
	cp gaussian_opencl_version/gaussianElim_kernels.cl .
	g++ gaussian_opencl_version/*.cpp -I./gaussian_opencl_version/ -lOpenCL -o gaussian_hand_opencl

#run each of the implementations of the gaussian elimination benchmark and store the AIWC features in the local directory called "gaussian_results"
test_gaussian: gaussian_cuda gaussian_opencl gaussian_hand_opencl gaussian_openacc
	rm -rf gaussian_results; mkdir -p gaussian_results; mkdir -p gaussian_results/cuda; mkdir -p gaussian_results/opencl; mkdir -p gaussian_results/openacc && \
	./gaussian_cuda ./data/gaussian_matrix4.txt && \
	${OCLGRIND_BIN} --aiwc ./gaussian_opencl ./data/gaussian_matrix4.txt; mv aiwc_* gaussian_results/cuda && \
	${OCLGRIND_BIN} --aiwc ./gaussian_hand_opencl ./data/gaussian_matrix4.txt -p 0 -d 0; mv aiwc_* gaussian_results/opencl && \
	cd gaussian_openacc_version/bin; ${OCLGRIND_BIN} --aiwc ./gaussian_ACC ../../data/gaussian_matrix4.txt ; mv aiwc_* ../../gaussian_results/openacc && \
	cd ../.. && make rename_aiwc_features

test_gaussian_openacc: gaussian_openacc
	rm -rf gaussian_results; mkdir -p gaussian_results; mkdir -p gaussian_results/cuda; mkdir -p gaussian_results/opencl; mkdir -p gaussian_results/openacc && \
	cd gaussian_openacc_version/bin; ${OCLGRIND_BIN} --aiwc ./gaussian_ACC ../../data/gaussian_matrix4.txt ; mv aiwc_* ../../gaussian_results/openacc


rename_aiwc_features:
	for file in ./gaussian_results/*/*.csv; do \
		python3 ./oclgrind-feature-rename.py $${file}; \
	done

#######
# BFS #
#######
bfs: bfs_cuda bfs_opencl bfs_hand_opencl

bfs_cuda: bfs_cuda_version/bfs.cu
	nvcc bfs_cuda_version/bfs.cu -I./bfs_cuda_version -o bfs_cuda

bfs_opencl: bfs_cuda_version/bfs.cu
	${COCL} bfs_cuda_version/bfs.cu -I./bfs_cuda_version -o bfs_opencl

#Uses OpenARC to perform source-to-source translation from OpenACC -> OpenCL
bfs_openacc: ./bfs_openacc_version/bfs.c
	cd ./bfs_openacc_version; ${OPENARC_ARGS} ./O2Build.script; ${OPENARC_ARGS} make

#Uses OpenARC to perform source-to-source translation from OpenMP -> OpenCL
bfs_openmp: ./bfs_openmp_version/bfs.c
	cd ./bfs_openmp_version; ${OPENARC_ARGS} ./O2Build.script; ${OPENARC_ARGS} make; mv ./bin/bfs_ACC ./bin/bfs_OMP

bfs_hand_opencl: bfs_opencl_version/bfs.cpp bfs_opencl_version/CLHelper.h
	cp bfs_opencl_version/Kernels.cl ./bfs_kernels.cl
	g++ bfs_opencl_version/bfs.cpp -I./bfs_opencl_version/ -lOpenCL -o bfs_hand_opencl

test_bfs: bfs_cuda bfs_opencl bfs_hand_opencl
	./bfs_cuda ./data/bfs_graph1MW_6.txt;
	${OCLGRIND_BIN} --aiwc ./bfs_opencl ./data/bfs_graph1MW_6.txt;
	${OCLGRIND_BIN} --aiwc ./bfs_hand_opencl ./data/bfs_graph1MW_6.txt;
	cd bfs_openacc_version/bin; ${OCLGRIND_BIN} --aiwc  ./bfs_ACC ../../data/bfs_graph1MW_6.txt; cd ..;
	cd bfs_openmp_version/bin; OMP_NUM_THREADS=4 ${OCLGRIND_BIN} --aiwc ./bfs_OMP 4 ../../data/bfs_graph1MW_6.txt

############
# backprop #
############
backprop: backprop_opencl #backprop_cuda #bfs_hand_opencl

backprop_cuda: backprop_cuda_version/backprop_cuda_kernel.cu backprop_cuda_version/backprop_cuda.cu backprop_cuda_version/imagenet.c
	g++ backprop_cuda_version/backprop.h backprop_cuda_version/backprop.c backprop_cuda_version/facetrain.c backprop_cuda_version/imagenet.c -I./backprop_cuda_version -std=c++11 -fPIC -shared -o ./backprop_cuda_version/libSTUFF.so
	nvcc backprop_cuda_version/backprop.c backprop_cuda_version/facetrain.c backprop_cuda_version/imagenet.c backprop_cuda_version/backprop_cuda.cu -I./backprop_cuda_version -lm -o backprop_cuda

backprop_opencl: backprop_cuda_version/backprop_cuda.cu backprop_cuda_version/facetrain.c backprop_cuda_version/imagenet.c backprop_cuda_version/backprop_cuda_kernel.cu
	g++ backprop_cuda_version/backprop.h backprop_cuda_version/backprop.c backprop_cuda_version/facetrain.c backprop_cuda_version/imagenet.c -I./backprop_cuda_version -std=c++11 -fPIC -shared -o ./backprop_cuda_version/libSTUFF.so
	EXTRA_LINKER_ARGS="-Wl,-rpath,./backprop_cuda_version -Wl,-rpath,. -L./backprop_cuda_version -lSTUFF -lm" ${COCL} -I./backprop_cuda_version backprop_cuda_version/backprop_cuda.cu backprop_cuda_version/backprop_cuda_kernel.cu -g -o backprop_opencl
#	${COCL} backprop_cuda_version/backprop_cuda.cu -I./backprop_cuda_version -c -o backprop_opencl.o
#	gcc backprop_cuda_version/backprop.c backprop_cuda_version/facetrain.c backprop_cuda_version/imagenet.c -I./backprop_cuda_version backprop_opencl.o -o backprop_opencl

test_backprop: backprop_opencl
	./backprop_opencl 65536

###########
# hotspot #
###########
hotspot: hotspot_cuda hotspot_opencl #bfs_hand_opencl

hotspot_cuda: hotspot_cuda_version/hotspot.cu
	nvcc hotspot_cuda_version/hotspot.cu -o hotspot_cuda

hotspot_opencl: hotspot_cuda_version/hotspot.cu
	${COCL} hotspot_cuda_version/hotspot.cu -o hotspot_opencl

hotspot_hand_opencl: bfs_opencl_version/bfs.cpp bfs_opencl_version/CLHelper.h
	cp bfs_opencl_version/Kernels.cl ./bfs_kernels.cl
	g++ bfs_opencl_version/bfs.cpp -I./bfs_opencl_version/ -lOpenCL -o bfs_hand_opencl

test_bfs: bfs_cuda bfs_opencl bfs_hand_opencl
	./hotspot_cuda 512 2 2 ./data/hotspot_temp_512 ./data/hotspot_power_512 output.out
	${OCLGRIND_BIN} --aiwc ./bfs_opencl ./data/bfs_graph1MW_6.txt;
	${OCLGRIND_BIN} --aiwc ./bfs_hand_opencl ./data/bfs_graph1MW_6.txt;



#######
# CFD #
#######
cfd: cfd_cuda cfd_opencl #cfd_hand_opencl

cfd_cuda: cfd_cuda_version/euler3d.cu
	nvcc cfd_cuda_version/euler3d.cu -o cfd_cuda

cfd_opencl: cfd_cuda_version/euler3d.cu
	${COCL} cfd_cuda_version/euler3d.cu -o cfd_opencl

###########
# Myocyte #
###########
myocyte: myocyte_cuda myocyte_opencl myocyte_hand_opencl
util: ./util/file/file.c ./util/num/num.c ./util/opencl/opencl.c ./util/timer/timer.c
	gcc -I./util/file ./util/file/file.c -I./util/num ./util/num/num.c -I./util/opencl ./util/opencl/opencl.c -I./util/timer ./util/timer/timer.c  -fPIC -shared -o ./util/libutil.so
UTIL_LD  := -Wl,-rpath,./util -L./util -lutil
UTIL_INC := -I./util -I./

myocyte_cuda: util ./myocyte_cuda_version/main.cu
	nvcc ./myocyte_cuda_version/main.cu ${UTIL_INC} -c -o ./myocyte_cuda_version/main.o
	g++ ./myocyte_cuda_version/main.o ./util/timer/timer.c ./util/file/file.c -L/usr/local/cuda/lib64 -lcuda -lcudart -lm ${UTIL_LD} -o myocyte_cuda

myocyte_opencl: ./myocyte_cuda_version/main.cu
	EXTRA_LINKER_ARGS="${UTIL_LD} -lm" ${COCL} ./myocyte_cuda_version/main.cu ${UTIL_INC} -I./myocyte_cuda_version -o myocyte_opencl

myocyte_hand_opencl: util ./myocyte_opencl_version/main.c ./myocyte_opencl_version/kernel/kernel_gpu_opencl.cl
	gcc ./myocyte_opencl_version/main.c ./myocyte_opencl_version/main.h ./myocyte_opencl_version/common.h ./myocyte_opencl_version/kernel/kernel_gpu_opencl_wrapper.c -lOpenCL -lm ${UTIL_LD} ${UTIL_INC} -o myocyte_hand_opencl
	cp ./myocyte_opencl_version/kernel/kernel_gpu_opencl.cl ./myocyte_hand_opencl_kernel.cl

test_myocyte: myocyte_cuda myocyte_hand_opencl
	./myocyte_cuda 100 1 0
	${OCLGRIND_BIN} --aiwc ./myocyte_hand_opencl -time 100


#############
# Heartwall #
#############
heartwall: heartwall_cuda heartwall_opencl heartwall_hand_opencl
avi: ./deps/avi/avilib.c ./deps/avi/avimod.c
	gcc ./deps/avi/avilib.c -I./deps/avi/ -fPIC -shared -o ./deps/avi/libavilib.so
	gcc ./deps/avi/avimod.c -I./deps/avi/ -fPIC -shared -o ./deps/avi/libavimod.so

AVI_LINKER_ARGS:=-Wl,-rpath,./deps/avi -L./deps/avi -lavimod -lavilib
AVI_INCLUDES := -I./deps/avi

heartwall_cuda: heartwall_cuda_version/main.cu heartwall_cuda_version/setdevice.cu heartwall_cuda_version/kernel.cu heartwall_cuda_version/define.c avi
	nvcc heartwall_cuda_version/main.cu ${AVI_INCLUDES} -I./heartwall_cuda_version -c -o heartwall_cuda_version/main.o
	g++ heartwall_cuda_version/main.o -L/usr/local/cuda/lib64 -lcuda -lcudart ${AVI_LINKER_ARGS} -o heartwall_cuda

heartwall_opencl: avi heartwall_cuda_version/main.cu
	EXTRA_LINKER_ARGS="${AVI_LINKER_ARGS}" ${COCL} heartwall_cuda_version/main.cu ${AVI_INCLUDES} -I./heartwall_cuda_version -o heartwall_cuda -o ./heartwall_opencl

heartwall_hand_opencl: heartwall_hand_opencl_version/main.c heartwall_hand_opencl_version/kernel/kernel_gpu_opencl_wrapper.c  heartwall_hand_opencl_version/util/file/file.c heartwall_hand_opencl_version/util/opencl/opencl.c heartwall_hand_opencl_version/util/timer/timer.c avi
	 gcc heartwall_hand_opencl_version/main.c heartwall_hand_opencl_version/kernel/kernel_gpu_opencl_wrapper.c heartwall_hand_opencl_version/util/file/file.c heartwall_hand_opencl_version/util/opencl/opencl.c heartwall_hand_opencl_version/util/timer/timer.c -I./heartwall_hand_opencl_version/ -I./deps/avi -I./heartwall_hand_opencl_version/kernel/  -I./heartwall_hand_opencl_version/util/file/ -I./heartwall_hand_opencl_version/util/opencl/ -I./heartwall_hand_opencl_version/util/timer/ -o heartwall_hand_opencl -lOpenCL ${AVI_LINKER_ARGS}

test_heartwall: heartwall_cuda heartwall_hand_opencl
	./heartwall_cuda ./data/heartwall_video.avi 5 && \
	./heartwall_opencl ./data/heartwall_video.avi 5 && \
	${OCLGRIND_BIN} --aiwc ./heartwall_hand_opencl 5

clean:
	rm -f *.ll *.o gaussian_cuda gaussian_opencl gaussian_hand_opencl myocyte_hand_opencl *.cl aiwc_* heartwall_cuda heartwall_opencl heartwall_hand_opencl backprop_opencl bfs_cuda bfs_opencl bfs_hand_opencl -r gaussian_openacc_version/cetus_output gaussian_openacc_version/bin

