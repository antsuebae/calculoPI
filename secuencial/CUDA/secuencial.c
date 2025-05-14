#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char *argv[]) {
    long num_steps = 100000;  // Valor por defecto
    if (argc > 1)
        num_steps = atol(argv[1]);

    double step = 1.0 / (double)num_steps;
    double sum = 0.0, x;
    long i;

    // Medir tiempo de ejecución
    clock_t start = clock();

    for (i = 0; i < num_steps; i++) {
        x = (i + 0.5) * step;
        sum += 4.0 / (1.0 + x * x);
    }

    double pi = step * sum;

    clock_t end = clock();
    double time_taken = ((double)(end - start)) / CLOCKS_PER_SEC;

    printf("Valor estimado de pi: %.7f\n", pi);
    printf("Tiempo de ejecución: %.6f segundos\n", time_taken);

    return 0;
}
