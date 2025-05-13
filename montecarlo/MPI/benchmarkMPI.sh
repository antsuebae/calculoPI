#!/bin/bash

cd "$(dirname "$0")"

EXECUTABLE=pi_montecarlo_MPI
OUTPUT_FILE="resultados_MPI.csv"

STEPS=(1000 10000 100000 1000000 10000000)
PROCESSES=(1 2 4 8 16 20)

echo "🔨 Compilando $EXECUTABLE.c con MPI..."
mpicc -o $EXECUTABLE $EXECUTABLE.c

echo "num_steps,num_procs,serial_time,parallel_time,speedup,diff_pi" > $OUTPUT_FILE

for steps in "${STEPS[@]}"; do
    for np in "${PROCESSES[@]}"; do

        echo "⏳ Ejecutando con $steps pasos y $np procesos..."

        OUTPUT=$(mpirun --oversubscribe -np $np ./$EXECUTABLE $steps 2>&1)
        EXIT_CODE=$?

        if [ "$EXIT_CODE" -ne 0 ]; then
            echo "❌ Error en ejecución con $steps pasos y $np procesos (mpirun falló)"
            continue
        fi

        serial_time=$(echo "$OUTPUT" | grep "Versión Serie" -A1 | tail -n1 | awk '{print $2}')
        parallel_time=$(echo "$OUTPUT" | grep "Versión Paralela" -A1 | tail -n1 | awk '{print $2}')
        speedup=$(echo "$OUTPUT" | grep "Speedup" | awk '{print $2}' | tr -d 'x')
        diff_pi=$(echo "$OUTPUT" | grep "Diferencia en π" | awk '{print $4}')

        if [[ -z "$serial_time" || -z "$parallel_time" || -z "$speedup" || -z "$diff_pi" ]]; then
            echo "❌ No se pudieron extraer datos correctamente con $steps pasos y $np procesos"
            continue
        fi

        echo "$steps,$np,$serial_time,$parallel_time,$speedup,$diff_pi" >> $OUTPUT_FILE
    done
done

echo "✅ Benchmark completado. Resultados guardados en $OUTPUT_FILE"
