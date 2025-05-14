#!/bin/bash

# Nombre del archivo de salida CSV
OUTPUT="resultados_CUDA.csv"

# Limpiar resultados anteriores
rm -f $OUTPUT

# Compilar los códigos CUDA y secuencial
echo "Compilando secuencial.cu (CUDA)..."
nvcc -I/opt/cuda/include -O3 secuencial.cu -o secuencial -lcurand || { echo "Fallo al compilar secuencial.cu"; exit 1; }

echo "Compilando secuencial.c (secuencial)..."
gcc -O3 secuencial.c -o secuencial -lm || { echo "Fallo al compilar secuencial.c"; exit 1; }

# Encabezado del CSV
echo "Metodo,Puntos,Tiempo(s),Pi,Aceleracion" > $OUTPUT

# Lista de muestras
SAMPLES_LIST=(100000 1000000 10000000 100000000 1000000000)

# Ejecutar benchmarks para secuencial
echo "Ejecutando benchmarks de secuencial..."
for SAMPLES in "${SAMPLES_LIST[@]}"; do
    echo " -> $SAMPLES muestras"

    # Ejecutar secuencial secuencial
    SEQ_OUTPUT=$(./secuencial $SAMPLES)
    SEQ_TIME=$(echo $SEQ_OUTPUT | grep -oP "(?<=Tiempo de ejecución: )\S+")
    SEQ_PI=$(echo $SEQ_OUTPUT | grep -oP "(?<=Valor estimado de pi: )\S+")

    # Ejecutar secuencial CUDA
    CUDA_OUTPUT=$(./secuencial $SAMPLES)
    CUDA_TIME=$(echo $CUDA_OUTPUT | grep -oP "(?<=Tiempo de ejecución: )\S+")
    CUDA_PI=$(echo $CUDA_OUTPUT | grep -oP "(?<=Valor estimado de pi: )\S+")

    # Calcular Aceleración
    if (( $(echo "$SEQ_TIME > 0" | bc -l) )); then
        ACCELERATION=$(echo "$SEQ_TIME / $CUDA_TIME" | bc -l)
    else
        ACCELERATION="N/A"
    fi

    # Imprimir resultados para cada número de muestras
    echo "Secuencial,$SAMPLES,$SEQ_TIME,$SEQ_PI,N/A" >> $OUTPUT
    echo "CUDA,$SAMPLES,$CUDA_TIME,$CUDA_PI,$ACCELERATION" >> $OUTPUT
done

echo "Benchmark completado ✅"
echo "Resultados guardados en $OUTPUT"
