#!/bin/bash

# Archivos
SOURCE="pi_montecarlo_OpenMP+MPI.c"
EXEC="pi_montecarlo_OpenMP+MPI"
OUTPUT="resultados_OpenMP+MPI.csv"

# Compilación
echo "🔨 Compilando $SOURCE con MPI + OpenMP..."
mpicc -fopenmp -o $EXEC $SOURCE
if [ $? -ne 0 ]; then
    echo "❌ Error al compilar."
    exit 1
fi

# Parámetros
STEPS_LIST=(1000 10000 100000 1000000 10000000)
PROCESSES_LIST=(1 2 4 8 16 20)
THREADS_LIST=(1 2 4 8 16 20)

# Cabecera del CSV
echo "muestras,procesos,hilos,pi_paralelo,tiempo_paralelo,speedup,diferencia_pi" > $OUTPUT

# Benchmark
for muestras in "${STEPS_LIST[@]}"; do
    for procesos in "${PROCESSES_LIST[@]}"; do
        for hilos in "${THREADS_LIST[@]}"; do
            echo "⏳ Ejecutando con $muestras muestras, $procesos procesos y $hilos hilos..."
            
            export OMP_NUM_THREADS=$hilos
            SALIDA=$(mpirun --oversubscribe -np $procesos ./$EXEC $muestras)

            # Extraer datos del output
            PI_PAR=$(echo "$SALIDA" | grep "Versión Paralela" -A2 | grep "Pi:" | awk '{print $2}')
            TIME_PAR=$(echo "$SALIDA" | grep "Versión Paralela" -A2 | grep "Tiempo" | awk '{print $2}')
            SPEEDUP=$(echo "$SALIDA" | grep "Speedup" | awk '{print $2}' | sed 's/x//')
            DIFF_PI=$(echo "$SALIDA" | grep "Diferencia en π" | awk '{print $4}')

            # Validar
            if [[ -z "$PI_PAR" || -z "$TIME_PAR" || -z "$SPEEDUP" || -z "$DIFF_PI" ]]; then
                echo "❌ Datos incompletos para $muestras muestras, $procesos procesos y $hilos hilos"
                continue
            fi

            # Guardar en CSV
            echo "$muestras,$procesos,$hilos,$PI_PAR,$TIME_PAR,$SPEEDUP,$DIFF_PI" >> $OUTPUT
        done
    done
done

echo "✅ Benchmark completado. Resultados guardados en $OUTPUT"
