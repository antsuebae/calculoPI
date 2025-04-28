#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>

int main(int argc, char *argv[]) {
    // Inicialización MPI
    MPI_Init(&argc, &argv);

    int my_id, num_procs;
    MPI_Comm_rank(MPI_COMM_WORLD, &my_id);
    MPI_Comm_size(MPI_COMM_WORLD, &num_procs);

    if (argc != 2) {
        if (my_id == 0) {
            printf("Uso correcto: %s <num_steps>\n", argv[0]);
        }
        MPI_Finalize();
        return 1;
    }

    long num_steps = atol(argv[1]);
    double step = 1.0 / (double)num_steps;
    double pi_serial = 0.0, pi_parallel = 0.0;
    double serial_time = 0.0, parallel_time = 0.0;

    // Versión Serie (solo proceso 0)
    if (my_id == 0) {
        double start = MPI_Wtime();
        double sum_serial = 0.0;
        for (long i = 0; i < num_steps; i++) {
            double x = (i + 0.5) * step;
            sum_serial += 4.0 / (1.0 + x * x);
        }
        pi_serial = step * sum_serial;
        serial_time = MPI_Wtime() - start;
    }

    MPI_Barrier(MPI_COMM_WORLD);

    // Versión Paralela MPI
    double parallel_start = MPI_Wtime();
    double local_sum = 0.0;
    
    long chunk_size = num_steps / num_procs;
    long start = my_id * chunk_size;
    long end = (my_id == num_procs - 1) ? num_steps : start + chunk_size;
    
    for (long i = start; i < end; i++) {
        double x = (i + 0.5) * step;
        local_sum += 4.0 / (1.0 + x * x);
    }
    
    double global_sum;
    MPI_Reduce(&local_sum, &global_sum, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);
    
    if (my_id == 0) {
        pi_parallel = step * global_sum;
        parallel_time = MPI_Wtime() - parallel_start;
        
        printf("\nResultados con %ld pasos y %d procesos:\n", num_steps, num_procs);
        printf("---------------------------------\n");
        printf("Versión Serie:\n");
        printf("  Tiempo: %.6f segundos\n", serial_time);
        printf("  Pi: %.12f\n", pi_serial);
        printf("\nVersión Paralela (MPI):\n");
        printf("  Tiempo: %.6f segundos\n", parallel_time);
        printf("  Pi: %.12f\n", pi_parallel);
        printf("---------------------------------\n");
        printf("Speedup: %.2fx\n", serial_time/parallel_time);
        printf("Diferencia en π: %e\n", fabs(pi_parallel - pi_serial));
    }

    MPI_Finalize();
    return 0;
}
