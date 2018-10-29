all: cpu-mandelbrot-vectorization

cpu-mandelbrot-vectorization: cpu-mandelbrot-vectorization.cpp
	g++ cpu-mandelbrot-vectorization.cpp -o cpu-mandelbrot-vectorization -lOpenCL -llsb -L$(LSB)/lib -I$(LSB)/include -std=c++11

clean:
	rm -f lsb.*.r0* aiwc_*.csv aiwc_*_itb.log Rplots.pdf cpu-mandelbrot-vectorization

