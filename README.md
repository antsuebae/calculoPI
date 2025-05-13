# Proyecto de Benchmarking: Cálculo de Pi

Este proyecto tiene como objetivo realizar un benchmarking comparativo del cálculo del número Pi utilizando diferentes algoritmos y tecnologías de paralelización. Se exploran dos enfoques principales para el cálculo de Pi: un método secuencial (basado en series o fórmulas) y el método de Montecarlo. Para cada enfoque, se implementan y evalúan versiones utilizando MPI, OpenMP y una combinación híbrida de OpenMP+MPI.

## Descripción

El proyecto consiste en una serie de scripts y programas que:
1.  Calculan el valor de Pi utilizando diferentes métodos y niveles de paralelismo.
2.  Miden el tiempo de ejecución para cada combinación de método y tecnología.
3.  Generan gráficas para visualizar y comparar el rendimiento obtenido.

Los métodos evaluados son:
*   **Secuencial:**
    *   MPI
    *   OpenMP
    *   OpenMP + MPI
*   **Montecarlo:**
    *   MPI
    *   OpenMP
    *   OpenMP + MPI

## Estructura del Proyecto

El proyecto está organizado de la siguiente manera:

```
/
├── index.sh                # Script principal para ejecutar todos los benchmarks y graficaciones
├── secuencial/
│   ├── MPI/
│   │   ├── benchmarkMPI.sh
│   │   ├── graficar_MPI.py
│   │   └── ... (código fuente de la implementación MPI)
│   ├── OpenMP/
│   │   ├── benchmarkOpenMP.sh
│   │   ├── graficar_OpenMP.py
│   │   └── ... (código fuente de la implementación OpenMP)
│   └── OpenMP+MPI/
│       ├── benchmarkOpenMP+MPI.sh
│       ├── graficar_OpenMP+MPI.py
│       └── ... (código fuente de la implementación OpenMP+MPI)
├── montecarlo/
│   ├── MPI/
│   │   ├── benchmarkMPI.sh
│   │   ├── graficar_MPI.py
│   │   └── ... (código fuente de la implementación MPI)
│   ├── OpenMP/
│   │   ├── benchmarkOpenMP.sh
│   │   ├── graficar_OpenMP.py
│   │   └── ... (código fuente de la implementación OpenMP)
│   └── OpenMP+MPI/
│       ├── benchmarkOpenMP+MPI.sh
│       ├── graficar_OpenMP+MPI.py
│       └── ... (código fuente de la implementación OpenMP+MPI)
└── README.md               # Este archivo
└── conclusiones.txt         # Archivo con las conclusiones del estudio (si existe)
```

*   `index.sh`: Orquesta la ejecución de todos los benchmarks y la posterior generación de gráficas.
*   Cada subdirectorio bajo `secuencial/` y `montecarlo/` representa una tecnología de paralelización (MPI, OpenMP, OpenMP+MPI).
*   Dentro de estos subdirectorios:
    *   `benchmark<TECNOLOGIA>.sh`: Script que compila (si es necesario) y ejecuta el programa de cálculo de Pi, midiendo su rendimiento y generando un archivo de resultados (generalmente un `.csv`).
    *   `graficar_<TECNOLOGIA>.py`: Script de Python que toma los resultados del benchmark y genera gráficas comparativas.

## Requisitos Previos

Para ejecutar este proyecto, necesitarás:
*   Un sistema operativo tipo Unix (Linux, macOS).
*   **Bash**: Para ejecutar los scripts `.sh`.
*   **Compilador de C/C++**: Como GCC (g++), con soporte para OpenMP.
*   **Implementación de MPI**: Como OpenMPI o MPICH (y sus correspondientes compiladores `mpicc`, `mpicxx`).
*   **Python 3**: Para los scripts de graficación.
*   **Librerías de Python**:
    *   `pandas` (para manipulación de datos)
    *   `matplotlib` (para generar gráficas)
    *   Puedes instalarlas con pip: `pip install pandas matplotlib`

## Ejecución

1.  Asegúrate de tener todos los Requisitos Previos instalados y configurados en tu sistema.
2.  Clona o descarga este repositorio.
3.  Navega al directorio raíz del proyecto: `cd /ruta/a/calculoPI`
4.  Otorga permisos de ejecución al script principal: `chmod +x index.sh`
5.  Ejecuta el script principal: `./index.sh`

El script `index.sh` se encargará de navegar a cada subdirectorio, ejecutar los benchmarks correspondientes y luego generar las gráficas. Los archivos de resultados (CSV) y las gráficas se guardarán dentro de sus respectivos subdirectorios (por ejemplo, `secuencial/MPI/resultados_MPI.csv` y `secuencial/MPI/graficasMPI/`).

## Conclusiones

El rendimiento de los métodos para calcular Pi varía significativamente según cómo ajustemos ciertos parámetros clave, como el número de **pasos** (para el método de series), el número de **muestras** (para Montecarlo), la cantidad de **hilos** (en OpenMP) y el número de **procesos** (en MPI). A continuación, se detallan estas observaciones:

### 1. Método Secuencial (Basado en Series)

Este método busca precisión a través de un cálculo iterativo.

*   **Impacto de los "Pasos" (Iteraciones):**
    *   Aumentar el número de **pasos** mejora la precisión del Pi calculado. Sin embargo, cada paso adicional incrementa linealmente el trabajo computacional base.
    *   Para la paralelización, un mayor número de pasos significa más trabajo total que puede ser dividido, lo que puede ser beneficioso hasta cierto punto.
*   **MPI:**
    *   Al aumentar el número de **procesos MPI** para una cantidad fija de pasos, el tiempo de ejecución tiende a disminuir, ya que cada proceso maneja una porción más pequeña de la serie.
    *   Sin embargo, con demasiados procesos para pocos pasos, el tiempo gastado en comunicación para sumar los resultados parciales puede superar el beneficio de la división del trabajo. Se busca un equilibrio.
*   **OpenMP:**
    *   Incrementar el número de **hilos OpenMP** en un sistema multinúcleo suele acelerar el cálculo de los términos de la serie, hasta que se alcanza el límite de núcleos físicos o por la sobrecarga de la directiva `reduction` (usada para combinar resultados).
    *   Para un número fijo de pasos, más hilos pueden procesarlos más rápido, pero la ganancia disminuye si los hilos compiten mucho por la memoria o si el trabajo por hilo es muy pequeño.
*   **OpenMP+MPI (Híbrido):**
    *   Esta combinación permite ajustar tanto los **procesos MPI** (entre nodos o grupos de núcleos) como los **hilos OpenMP** (dentro de cada proceso/nodo).
    *   Para una gran cantidad de pasos, se puede distribuir la carga eficientemente: MPI divide grandes rangos de la serie, y OpenMP acelera el cálculo de los términos dentro de esos rangos asignados a cada proceso MPI. Esto ayuda a optimizar el uso de recursos en clústeres.

### 2. Método de Montecarlo

Este método se basa en la probabilidad y requiere un gran número de "intentos".

*   **Impacto de las "Muestras":**
    *   Aumentar el número de **muestras** mejora la precisión del Pi calculado, pero la mejora es más lenta (proporcional a la raíz cuadrada del número de muestras). Cada muestra adicional también incrementa el trabajo computacional.
    *   La naturaleza independiente de cada muestra hace que este método sea ideal para paralelizar: más muestras simplemente significan más tareas independientes.
*   **MPI:**
    *   El rendimiento escala muy bien al aumentar el número de **procesos MPI**. Si se duplican los procesos, el tiempo para generar un número fijo de muestras tiende a reducirse a la mitad, ya que cada proceso genera una fracción de las muestras totales.
    *   La comunicación es mínima (solo para agregar aciertos), por lo que el costo adicional por usar más procesos es bajo.
*   **OpenMP:**
    *   Aumentar el número de **hilos OpenMP** acelera la generación de un número fijo de muestras en sistemas multinúcleo. Cada hilo puede generar su propio subconjunto de muestras.
    *   La escalabilidad es generalmente buena, aunque puede verse limitada si el generador de números aleatorios no es eficiente para múltiples hilos o si hay mucha competencia al sumar los aciertos (si no se maneja con cuidado).
*   **OpenMP+MPI (Híbrido):**
    *   Permite generar un volumen masivo de muestras. Los **procesos MPI** distribuyen la tarea de generar grandes lotes de muestras entre diferentes nodos/procesadores, y los **hilos OpenMP** dentro de cada proceso aceleran la generación de su lote asignado.
    *   Es muy efectivo para maximizar la cantidad de muestras en un tiempo dado.

### 3. Consideraciones Generales sobre Paralelización y Parámetros

*   **Balance Carga-Paralelismo:** En todos los casos, es crucial encontrar un equilibrio. Dividir una tarea muy pequeña (pocos pasos o muestras) entre demasiados procesos o hilos puede ser contraproducente debido al costo adicional de la paralelización (comunicación, gestión de hilos).
*   **Granularidad:** El "tamaño" de la tarea asignada a cada unidad paralela (proceso/hilo) es importante. Tareas demasiado pequeñas ("grano fino") pueden sufrir por el costo de gestión. Tareas demasiado grandes ("grano grueso") pueden no aprovechar todo el paralelismo disponible o llevar a que algunos procesadores terminen antes y queden ociosos.
*   **Naturaleza del Problema y Overhead:** El método de Montecarlo, al ser fácilmente paralelizable (cada muestra es independiente), tiende a escalar de forma más predecible y eficiente con más procesos/hilos, especialmente cuando el número de muestras es alto. El método de series, con su necesidad de combinar resultados parciales (reducción), puede enfrentar mayores costos de comunicación o sincronización a medida que aumenta el número de procesos/hilos, especialmente si el número de pasos por proceso/hilo es bajo.