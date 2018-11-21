all: cpu-mandelbrot-vectorization aiwc-tester

test: aiwc-tester
	$(OCLGRIND)/bin/oclgrind --workload-characterisation ./aiwc-tester ./simple-aiwc-tests.cl tiny 0 0 aiwc

cpu-mandelbrot-vectorization: cpu-mandelbrot-vectorization.cpp
	g++ cpu-mandelbrot-vectorization.cpp -o cpu-mandelbrot-vectorization -lOpenCL -llsb -L$(LSB)/lib -I$(LSB)/include -std=c++11

aiwc-tester: aiwc-tester.cpp
	g++ aiwc-tester.cpp -o aiwc-tester -lOpenCL -llsb -L$(LSB)/lib -I$(LSB)/include -std=c++11

clean:
	rm -f lsb.*.r0* aiwc_*.csv aiwc_*_itb.log Rplots.pdf cpu-mandelbrot-vectorization aiwc-tester

