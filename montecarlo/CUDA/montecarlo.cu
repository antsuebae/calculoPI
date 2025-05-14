#include <cstdio>
#include <cstdlib>
#include <curand_kernel.h>
#include <chrono>
#include <cuda_runtime.h>

__global__ void montecarlo_kernel(long long total_points, unsigned long long *d_count, unsigned int seed) {
    unsigned long long local_count = 0;
    long long idx = blockIdx.x * blockDim.x + threadIdx.x;
    long long stride = gridDim.x * blockDim.x;

    curandState state;
    curand_init(seed, idx, 0, &state);

    for (long long i = idx; i < total_points; i += stride) {
        float x = curand_uniform(&state);
        float y = curand_uniform(&state);
        if (x * x + y * y <= 1.0f)
            local_count++;
    }

    atomicAdd(d_count, local_count);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        std::fprintf(stderr, "Uso: %s <num_puntos>\n", argv[0]);
        return EXIT_FAILURE;
    }

    long long total_points = std::atoll(argv[1]);
    unsigned long long *d_count, h_count = 0;

    cudaMalloc(&d_count, sizeof(unsigned long long));
    cudaMemset(d_count, 0, sizeof(unsigned long long));

    int threads_per_block = 256;
    int blocks = 128;  // Puedes ajustar esto según la GPU

    auto start = std::chrono::high_resolution_clock::now();
    montecarlo_kernel<<<blocks, threads_per_block>>>(total_points, d_count, time(NULL));
    cudaDeviceSynchronize();
    auto end = std::chrono::high_resolution_clock::now();

    cudaMemcpy(&h_count, d_count, sizeof(unsigned long long), cudaMemcpyDeviceToHost);
    cudaFree(d_count);

    double pi = 4.0 * static_cast<double>(h_count) / static_cast<double>(total_points);
    double tiempo = std::chrono::duration<double>(end - start).count();

    // Salida estructurada
    std::printf("\nResultados - CUDA Monte Carlo\n");
    std::printf("---------------------------------\n");
    std::printf("Puntos totales: %lld\n", total_points);
    std::printf("Puntos dentro del círculo: %llu\n", h_count);
    std::printf("Tiempo de ejecución: %.6f segundos\n", tiempo);
    std::printf("Estimación de π: %.12f\n", pi);
    std::printf("---------------------------------\n");

    return 0;
}