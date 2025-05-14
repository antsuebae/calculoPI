#!/bin/bash

# Nombre del archivo de salida CSV
OUTPUT="resultados_CUDA.csv"

# Limpiar resultados anteriores
rm -f $OUTPUT

# Compilar los códigos CUDA y secuencial
echo "Compilando montecarlo.cu (CUDA)..."
nvcc -I/opt/cuda/include -O3 montecarlo.cu -o montecarlo -lcurand || { echo "Fallo al compilar montecarlo.cu"; exit 1; }

echo "Compilando montecarlo.c (secuencial)..."
gcc -O3 montecarlo.c -o montecarlo -lm || { echo "Fallo al compilar montecarlo.c"; exit 1; }

# Encabezado del CSV
echo "Metodo,Puntos,Tiempo(s),Pi,Aceleracion" > $OUTPUT

# Lista de muestras
SAMPLES_LIST=(100000 1000000 10000000 100000000 1000000000)

# Ejecutar benchmarks para montecarlo
echo "Ejecutando benchmarks de Montecarlo..."
for SAMPLES in "${SAMPLES_LIST[@]}"; do
    echo " -> $SAMPLES muestras"

    # Ejecutar Montecarlo secuencial
    SEQ_OUTPUT=$(./montecarlo $SAMPLES)
    SEQ_TIME=$(echo $SEQ_OUTPUT | grep -oP "(?<=Tiempo de ejecución: )\S+")
    SEQ_PI=$(echo $SEQ_OUTPUT | grep -oP "(?<=Valor estimado de pi: )\S+")

    # Ejecutar Montecarlo CUDA
    CUDA_OUTPUT=$(./montecarlo $SAMPLES)
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
