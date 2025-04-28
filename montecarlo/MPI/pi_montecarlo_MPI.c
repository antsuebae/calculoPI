#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <time.h>
#include <math.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Uso: %s <num_muestras>\n", argv[0]);
        return 1;
    }

    unsigned long long muestras = atoll(argv[1]);

    double pi_serial = 0.0, pi_parallel = 0.0;
    double serial_time = 0.0, parallel_time = 0.0;

    unsigned long long count_serial = 0;
    unsigned long long count_parallel = 0;
    double start, end;

    // ================================
    // Versión Serie (solo en rank 0)
    // ================================
    start = MPI_Wtime();
    unsigned short xi[3] = {1, 2, 3};

    for (unsigned long long i = 0; i < muestras; ++i) {
        double x = erand48(xi);
        double y = erand48(xi);
        if (x * x + y * y <= 1.0) {
            ++count_serial;
        }
    }
    pi_serial = 4.0 * count_serial / muestras;
    end = MPI_Wtime();
    serial_time = end - start;

    // ================================
    // Inicializar MPI
    // ================================
    int rank, size;
    MPI_Init(&argc, &argv);                  
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);     
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // ================================
    // Versión Paralela MPI
    // ================================
    unsigned long long muestras_local = muestras / size;
    unsigned short xi_priv[3] = { (unsigned short)(rank + 1), (unsigned short)(rank + 2), (unsigned short)(rank + 3) };
    unsigned long long local_count = 0;

    MPI_Barrier(MPI_COMM_WORLD);  // Sincronizar antes de medir tiempo
    start = MPI_Wtime();

    for (unsigned long long i = 0; i < muestras_local; ++i) {
        double x = erand48(xi_priv);
        double y = erand48(xi_priv);
        if (x * x + y * y <= 1.0) {
            ++local_count;
        }
    }

    // Reducir los conteos locales
    MPI_Reduce(&local_count, &count_parallel, 1, MPI_UNSIGNED_LONG_LONG, MPI_SUM, 0, MPI_COMM_WORLD);

    MPI_Barrier(MPI_COMM_WORLD);  // Sincronizar después de computar
    end = MPI_Wtime();
    parallel_time = end - start;

    // ================================
    // Resultados (solo en rank 0)
    // ================================
    if (rank == 0) {
        pi_parallel = 4.0 * count_parallel / muestras;

        printf("\nResultados con %llu muestras y %d procesos:\n", muestras, size);
        printf("---------------------------------\n");
        printf("Versión Serie:\n");
        printf("  Tiempo: %.6f segundos\n", serial_time);
        printf("  Pi: %.12f\n", pi_serial);
        printf("\nVersión Paralela MPI:\n");
        printf("  Tiempo: %.6f segundos\n", parallel_time);
        printf("  Pi: %.12f\n", pi_parallel);
        printf("---------------------------------\n");
        printf("Speedup: %.2fx\n", serial_time / parallel_time);
        printf("Diferencia en π: %e\n", fabs(pi_parallel - pi_serial));
    }

    MPI_Finalize();
    return 0;
}
