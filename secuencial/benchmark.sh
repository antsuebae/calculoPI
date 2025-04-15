#!/bin/bash

# Archivos
SOURCE="pi_secuencial_OpenMP.c"
EXEC="pi_secuencial_OpenMP"
OUTPUT="resultados_pi.csv"

# Compilación
echo "Compilando $SOURCE..."
gcc -fopenmp -o $EXEC $SOURCE
if [ $? -ne 0 ]; then
    echo "❌ Error al compilar."
    exit 1
fi

# Valores para probar
PASOS_LISTA=(1000 10000 100000 1000000 10000000)
HILOS_LISTA=(1 2 4 8 16 20)

# Cabecera del CSV
echo "pasos,hilos,pi_paralelo,tiempo_paralelo,speedup,diferencia_pi" > $OUTPUT

# Ejecución de pruebas
for pasos in "${PASOS_LISTA[@]}"; do
    for hilos in "${HILOS_LISTA[@]}"; do
        echo "⏳ Ejecutando con $pasos pasos y $hilos hilos..."
        SALIDA=$(./$EXEC $pasos $hilos)

        # Extraer datos usando grep + sed
        PI_PAR=$(echo "$SALIDA" | grep "Versión Paralela" -A2 | grep "Pi:" | sed 's/[^0-9.]//g')
        TIME_PAR=$(echo "$SALIDA" | grep "Versión Paralela" -A2 | grep "Tiempo" | awk '{print $2}')
        SPEEDUP=$(echo "$SALIDA" | grep "Speedup" | awk '{print $2}' | sed 's/x//')
        DIFF=$(echo "$SALIDA" | grep "Diferencia en π" | awk '{print $4}')

        # Escribir en CSV
        echo "$pasos,$hilos,$PI_PAR,$TIME_PAR,$SPEEDUP,$DIFF" >> $OUTPUT
    done
done

echo "✅ Pruebas completadas. Resultados guardados en $OUTPUT"
