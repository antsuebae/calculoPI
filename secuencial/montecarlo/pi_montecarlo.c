/*
 * Algoritmo serie de Monte Carlo para estimar el valor de pi
 */

#include <stdio.h>
#include <stdlib.h>

int main (int argc, char *argv[]) {
  unsigned short xi[3] = { 1, 2, 3 };
  unsigned long long count = 0;
  unsigned long long i;
  unsigned long long samples;
  double x, y;
  samples=3000000; /*Valor por defecto*/

  if (argc >1)
    samples = atoll(argv[1]);
    

  for (i = 0; i < samples; ++i) {
    x = erand48(xi);
    y = erand48(xi);
    if (x*x+y*y <= 1.0) {
      ++count;
    }
  }

  printf ("Valor estimado de pi:  %.7f\n", 4.0*count/samples);
  return 0;
}
