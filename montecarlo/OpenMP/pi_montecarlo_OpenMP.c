#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <time.h>
#include <math.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Uso: %s <num_muestras> <num_hilos>\n", argv[0]);
        return 1;
    }

    unsigned long long muestras = atoll(argv[1]);
    int num_hilos = atoi(argv[2]);

    double pi_serial = 0.0, pi_parallel = 0.0;
    double serial_time, parallel_time;

    // ================================
    // Versión Serie
    // ================================
    clock_t start = clock();
    unsigned long long count_serial = 0;
    unsigned short xi[3] = {1, 2, 3};

    for (unsigned long long i = 0; i < muestras; ++i) {
        double x = erand48(xi);
        double y = erand48(xi);
        if (x * x + y * y <= 1.0) {
            ++count_serial;
        }
    }
    pi_serial = 4.0 * count_serial / muestras;
    serial_time = ((double)(clock() - start)) / CLOCKS_PER_SEC;

    // ================================
    // Versión Paralela
    // ================================
    omp_set_num_threads(num_hilos);
    unsigned long long count_parallel = 0;

    start = clock();
    #pragma omp parallel
    {
        unsigned short xi_priv[3];
        int tid = omp_get_thread_num();
        xi_priv[0] = (unsigned short)(tid + 1);
        xi_priv[1] = (unsigned short)(tid + 2);
        xi_priv[2] = (unsigned short)(tid + 3);
        unsigned long long local_count = 0;

        #pragma omp for
        for (unsigned long long i = 0; i < muestras; ++i) {
            double x = erand48(xi_priv);
            double y = erand48(xi_priv);
            if (x * x + y * y <= 1.0) {
                ++local_count;
            }
        }

        #pragma omp atomic
        count_parallel += local_count;
    }
    pi_parallel = 4.0 * count_parallel / muestras;
    parallel_time = ((double)(clock() - start)) / CLOCKS_PER_SEC;

    // ================================
    // Resultados
    // ================================
    printf("\nResultados con %llu muestras y %d hilos:\n", muestras, num_hilos);
    printf("---------------------------------\n");
    printf("Versión Serie:\n");
    printf("  Tiempo: %.6f segundos\n", serial_time);
    printf("  Pi: %.12f\n", pi_serial);
    printf("\nVersión Paralela:\n");
    printf("  Tiempo: %.6f segundos\n", parallel_time);
    printf("  Pi: %.12f\n", pi_parallel);
    printf("---------------------------------\n");
    printf("Speedup: %.2fx\n", serial_time / parallel_time);
    printf("Diferencia en π: %e\n", fabs(pi_parallel - pi_serial));

    return 0;
}
