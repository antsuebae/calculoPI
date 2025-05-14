#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main (int argc, char *argv[]) {
    unsigned short xi[3] = { 1, 2, 3 };
    unsigned long long count = 0;
    unsigned long long i;
    unsigned long long samples;

    double x, y;

    samples = 3000000;  /* Valor por defecto */

    if (argc > 1)
        samples = atoll(argv[1]);

    // Medir el tiempo de ejecución
    clock_t start = clock();

    for (i = 0; i < samples; ++i) {
        x = erand48(xi);
        y = erand48(xi);
        if (x * x + y * y <= 1.0) {
            count++;  // Incremento correcto de count
        }
    }

    clock_t end = clock();
    double time_taken = ((double)(end - start)) / CLOCKS_PER_SEC;  // Tiempo en segundos

    printf("Valor estimado de pi: %.7f\n", 4.0 * count / samples);
    printf("Tiempo de ejecución: %.6f segundos\n", time_taken);

    return 0;
}
