all: cpu-mandelbrot-vectorization aiwc-tester simple-aiwc-tests.ll simple-aiwc-tests.bc

test: aiwc-tester simple-aiwc-tests.bc
	$(OCLGRIND)/bin/oclgrind --build-options "-cl-opt-disable -cl-std=CL1.2" --workload-characterisation ./aiwc-tester ./simple-aiwc-tests.cl tiny 0 0 aiwc

cpu-mandelbrot-vectorization: cpu-mandelbrot-vectorization.cpp
	g++ cpu-mandelbrot-vectorization.cpp -o cpu-mandelbrot-vectorization -lOpenCL -llsb -L$(LSB)/lib -I$(LSB)/include -std=c++11

aiwc-tester: aiwc-tester.cpp
	g++ aiwc-tester.cpp -o aiwc-tester -lOpenCL -llsb -L$(LSB)/lib -I$(LSB)/include -std=c++11

simple-aiwc-tests.ll: simple-aiwc-tests.cl
	clang -cc1 -triple spir64-unknown-unknown  -cl-std=CL1.2 -cl-spir-compile-options "-cl-std=CL1.2" ./simple-aiwc-tests.cl  -S -emit-llvm  -o simple-aiwc-tests.ll

simple-aiwc-tests.bc: simple-aiwc-tests.cl
	clang -cc1 -triple spir-unknown-unknown -cl-opt-disable -cl-std=CL1.2 -cl-spir-compile-options "-cl-opt-disable -cl-std=CL1.2 -DTILE_DIM=32" ./simple-aiwc-tests.cl  -S -emit-llvm-bc  -o simple-aiwc-tests.bc
#	clang -cc1 -triple spir64-unknown-unknown -DTILE_DIM=32 -O0 -cl-std=CL1.2 -cl-spir-compile-options "-O0 -DTILE_DIM=32 -cl-std=CL1.2" ./simple-aiwc-tests.cl  -S -emit-llvm-bc  -o simple-aiwc-tests.bc

clean:
	rm -f lsb.*.r0* aiwc_*.csv aiwc_*.log aiwc_*_itb.log Rplots.pdf cpu-mandelbrot-vectorization aiwc-tester simple-aiwc-tests.ll simple-aiwc-tests.bc 

