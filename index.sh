#!/bin/bash

# Obtener el tiempo de inicio
start_time=$(date +%s)

# Obtener el directorio donde reside el script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Cambiar al directorio del script para que las rutas relativas funcionen
cd "$SCRIPT_DIR"

echo "----------------------------------------------------"
echo "##INICIANDO PROCESO DE CÁLCULO DE PI##"
echo "----------------------------------------------------"

echo "➡️  Procesando: Secuencial MPI..."
cd secuencial/MPI
./benchmarkMPI.sh
python graficar_MPI.py
echo "✅ Completado: Secuencial MPI"
echo "----------------------------------------------------"

echo "➡️  Procesando: Secuencial OpenMP..."
cd ../OpenMP # Desde secuencial/MPI, subimos a secuencial/ y entramos a OpenMP/
./benchmarkOpenMP.sh
python graficar_OpenMP.py
echo "✅ Completado: Secuencial OpenMP"
echo "----------------------------------------------------"

echo "➡️  Procesando: Secuencial OpenMP+MPI..."
cd ../OpenMP+MPI # Desde secuencial/OpenMP, subimos a secuencial/ y entramos a OpenMP+MPI/
./benchmarkOpenMP+MPI.sh
python graficar_OpenMP+MPI.py
echo "✅ Completado: Secuencial OpenMP+MPI"
echo "----------------------------------------------------"

echo "➡️  Procesando: Montecarlo MPI..."
cd ../../montecarlo/MPI # Desde secuencial/OpenMP+MPI, subimos a secuencial/, luego a calculoPI/, y entramos a montecarlo/MPI/
./benchmarkMPI.sh
python graficar_MPI.py
echo "✅ Completado: Montecarlo MPI"
echo "----------------------------------------------------"

echo "➡️  Procesando: Montecarlo OpenMP..."
cd ../OpenMP # Desde montecarlo/MPI, subimos a montecarlo/ y entramos a OpenMP/
./benchmarkOpenMP.sh
python graficar_OpenMP.py
echo "✅ Completado: Montecarlo OpenMP"
echo "----------------------------------------------------"

echo "➡️  Procesando: Montecarlo OpenMP+MPI..."
cd ../OpenMP+MPI # Desde montecarlo/OpenMP, subimos a montecarlo/ y entramos a OpenMP+MPI/
./benchmarkOpenMP+MPI.sh
python graficar_OpenMP+MPI.py
echo "✅ Completado: Montecarlo OpenMP+MPI"

# Obtener el tiempo de fin
end_time=$(date +%s)

# Calcular la duración total en segundos
total_seconds=$((end_time - start_time))

# Calcular minutos y segundos
minutes=$((total_seconds / 60))
seconds=$((total_seconds % 60))

echo "----------------------------------------------------"
echo "###¡PROCESO FINALIZADO!###"
echo "----------------------------------------------------"

# Mostrar el tiempo total transcurrido en formato minutos:segundos
printf "Tiempo total transcurrido: %02d minutos %02d segundos.\n" "$minutes" "$seconds"

