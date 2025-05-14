#include <cstdio>
#include <cstdlib>
#include <chrono>
#include <cuda_runtime.h>

__global__ void pi_seq_kernel(long long N, double *result) {
    double h = 1.0 / static_cast<double>(N);
    double sum = 0.0;
    for (long long i = 0; i < N; ++i) {
        double x = (i + 0.5) * h;
        sum += 4.0 / (1.0 + x * x);
    }
    *result = sum * h;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        std::fprintf(stderr, "Uso: %s <num_muestras>\n", argv[0]);
        return EXIT_FAILURE;
    }

    long long muestras = std::atoll(argv[1]);
    double *d_result = nullptr;
    cudaMalloc(&d_result, sizeof(double));

    auto start = std::chrono::high_resolution_clock::now();
    pi_seq_kernel<<<1, 1>>>(muestras, d_result);
    cudaDeviceSynchronize();
    auto end = std::chrono::high_resolution_clock::now();

    double pi = 0.0;
    cudaMemcpy(&pi, d_result, sizeof(double), cudaMemcpyDeviceToHost);
    cudaFree(d_result);

    double tiempo = std::chrono::duration<double>(end - start).count();

    // Salida con formato estructurado
    std::printf("\nResultados - CUDA Secuencial\n");
    std::printf("---------------------------------\n");
    std::printf("Muestras: %llu\n", muestras);
    std::printf("Tiempo de ejecución: %.6f segundos\n", tiempo);
    std::printf("Estimación de π: %.12f\n", pi);
    std::printf("---------------------------------\n");

    return 0;
}