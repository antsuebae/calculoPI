#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <mpi.h>
#include <omp.h>

// Función para generar número aleatorio entre 0 y 1 usando erand48
double rand_uniform(unsigned short xi[3]) {
    return erand48(xi);
}

int main(int argc, char *argv[]) {
    // Inicialización MPI
    MPI_Init(&argc, &argv);

    int my_id, num_procs;
    MPI_Comm_rank(MPI_COMM_WORLD, &my_id);
    MPI_Comm_size(MPI_COMM_WORLD, &num_procs);

    if (argc != 2) {
        if (my_id == 0)
            printf("Uso correcto: %s <num_samples>\n", argv[0]);
        MPI_Finalize();
        return 1;
    }

    unsigned long long total_samples = atoll(argv[1]);
    unsigned long long local_samples = total_samples / num_procs;
    if (my_id == num_procs - 1) {
        local_samples += total_samples % num_procs;  // último proceso asume el resto
    }

    // ===== SERIAL (solo en proceso 0) =====
    double serial_pi = 0.0, serial_time = 0.0;
    if (my_id == 0) {
        unsigned long long count = 0;
        unsigned short xi[3] = {1, 2, 3};

        double t_start = MPI_Wtime();
        #pragma omp parallel
        {
            unsigned short thread_xi[3];
            int tid = omp_get_thread_num();
            thread_xi[0] = xi[0] + tid;
            thread_xi[1] = xi[1];
            thread_xi[2] = xi[2];

            unsigned long long local_count = 0;
            #pragma omp for
            for (unsigned long long i = 0; i < total_samples; i++) {
                double x = erand48(thread_xi);
                double y = erand48(thread_xi);
                if (x * x + y * y <= 1.0) {
                    local_count++;
                }
            }

            #pragma omp atomic
            count += local_count;
        }
        serial_pi = 4.0 * count / total_samples;
        serial_time = MPI_Wtime() - t_start;
    }

    MPI_Barrier(MPI_COMM_WORLD); // sincronización antes del paralelo

    // ===== PARALELO (MPI + OpenMP) =====
    double parallel_start = MPI_Wtime();
    unsigned long long local_count = 0;

    #pragma omp parallel
    {
        unsigned short xi[3];
        int tid = omp_get_thread_num();
        xi[0] = (unsigned short)(my_id + 1);
        xi[1] = (unsigned short)(tid + 2);
        xi[2] = (unsigned short)(1234 + tid);

        unsigned long long thread_count = 0;
        #pragma omp for
        for (unsigned long long i = 0; i < local_samples; i++) {
            double x = erand48(xi);
            double y = erand48(xi);
            if (x * x + y * y <= 1.0) {
                thread_count++;
            }
        }

        #pragma omp atomic
        local_count += thread_count;
    }

    unsigned long long total_count = 0;
    MPI_Reduce(&local_count, &total_count, 1, MPI_UNSIGNED_LONG_LONG, MPI_SUM, 0, MPI_COMM_WORLD);

    if (my_id == 0) {
        double parallel_time = MPI_Wtime() - parallel_start;
        double parallel_pi = 4.0 * total_count / total_samples;

        printf("\nResultados con %llu muestras y %d procesos:\n", total_samples, num_procs);
        printf("-------------------------------------------------\n");
        printf("Versión Serie (OpenMP):\n");
        printf("  Tiempo: %.6f segundos\n", serial_time);
        printf("  Pi: %.12f\n", serial_pi);
        printf("\nVersión Paralela (MPI + OpenMP):\n");
        printf("  Tiempo: %.6f segundos\n", parallel_time);
        printf("  Pi: %.12f\n", parallel_pi);
        printf("-------------------------------------------------\n");
        printf("Speedup: %.2fx\n", serial_time / parallel_time);
        printf("Diferencia en π: %e\n", fabs(parallel_pi - serial_pi));
    }

    MPI_Finalize();
    return 0;
}
