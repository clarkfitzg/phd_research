OS = $(shell uname)

CFLAGS = -lm

ifeq ($(OS), Linux)
	CFLAGS += -L /usr/local/cuda/lib64 -lOpenCL
endif
ifeq ($(OS), Darwin)
	CFLAGS += -framework OpenCL
endif

add1.o: add1.c add1.cl
	gcc -o $@ $< $(CFLAGS)

add1.so: add1.o
