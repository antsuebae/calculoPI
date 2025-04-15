#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <time.h>
#include <math.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Uso: %s <num_steps> <num_threads>\n", argv[0]);
        return 1;
    }

    long num_steps = atol(argv[1]);
    int num_threads = atoi(argv[2]);
    double step = 1.0 / (double)num_steps;
    double pi_serial, pi_parallel;
    clock_t start, end;

    // Versión Serie
    start = clock();
    double sum_serial = 0.0;
    for (long i = 0; i < num_steps; i++) {
        double x = (i + 0.5) * step;
        sum_serial += 4.0 / (1.0 + x * x);
    }
    pi_serial = step * sum_serial;
    end = clock();
    double serial_time = ((double)(end - start)) / CLOCKS_PER_SEC;

    // Versión Paralela
    omp_set_num_threads(num_threads);  // <- Aquí fijamos los hilos
    start = clock();
    double sum_parallel = 0.0;
    #pragma omp parallel for reduction(+:sum_parallel)
    for (long i = 0; i < num_steps; i++) {
        double x = (i + 0.5) * step;
        sum_parallel += 4.0 / (1.0 + x * x);
    }
    pi_parallel = step * sum_parallel;
    end = clock();
    double parallel_time = ((double)(end - start)) / CLOCKS_PER_SEC;

    // Resultados
    printf("\nResultados con %ld pasos y %d hilos:\n", num_steps, num_threads);
    printf("---------------------------------\n");
    printf("Versión Serie:\n");
    printf("  Tiempo: %.6f segundos\n", serial_time);
    printf("  Pi: %.12f\n", pi_serial);
    printf("\nVersión Paralela:\n");
    printf("  Tiempo: %.6f segundos\n", parallel_time);
    printf("  Pi: %.12f\n", pi_parallel);
    printf("---------------------------------\n");
    printf("Speedup: %.2fx\n", serial_time/parallel_time);
    printf("Diferencia en π: %e\n", fabs(pi_parallel - pi_serial));

    return 0;
}
