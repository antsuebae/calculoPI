import pandas as pd
import matplotlib.pyplot as plt
import os

# Configurar salida
output_dir = "graficasOpenMP+MPI"
os.makedirs(output_dir, exist_ok=True)

# Leer datos
df = pd.read_csv("resultados_OpenMP+MPI.csv")

# Conversión de tipos
df["muestras"] = df["muestras"].astype(int)
df["procesos"] = df["procesos"].astype(int)
df["hilos"] = df["hilos"].astype(int)
df["tiempo_paralelo"] = df["tiempo_paralelo"].astype(float)
df["speedup"] = df["speedup"].astype(float)
df["diferencia_pi"] = df["diferencia_pi"].astype(float)

# ===============================
# 1. Heatmap de tiempo de ejecución por procesos y hilos (para cada muestras)
# ===============================
for muestras in sorted(df["muestras"].unique()):
    pivot = df[df["muestras"] == muestras].pivot(index="procesos", columns="hilos", values="tiempo_paralelo")
    plt.figure(figsize=(10, 6))
    plt.imshow(pivot, cmap="YlGnBu", aspect='auto', interpolation="nearest")
    plt.colorbar(label="Tiempo (s)")
    plt.title(f"Tiempo Paralelo (s) - {muestras} muestras")
    plt.xlabel("Hilos")
    plt.ylabel("Procesos")
    plt.xticks(range(len(pivot.columns)), pivot.columns)
    plt.yticks(range(len(pivot.index)), pivot.index)
    plt.savefig(f"{output_dir}/heatmap_tiempo_{muestras}_muestras.png")
    plt.clf()

# ===============================
# 2. Heatmap de speedup por procesos y hilos (para cada muestras)
# ===============================
for muestras in sorted(df["muestras"].unique()):
    pivot = df[df["muestras"] == muestras].pivot(index="procesos", columns="hilos", values="speedup")
    plt.figure(figsize=(10, 6))
    plt.imshow(pivot, cmap="YlOrRd", aspect='auto', interpolation="nearest")
    plt.colorbar(label="Speedup")
    plt.title(f"Speedup - {muestras} muestras")
    plt.xlabel("Hilos")
    plt.ylabel("Procesos")
    plt.xticks(range(len(pivot.columns)), pivot.columns)
    plt.yticks(range(len(pivot.index)), pivot.index)
    plt.savefig(f"{output_dir}/heatmap_speedup_{muestras}_muestras.png")
    plt.clf()

# ===============================
# 3. Error en pi vs muestras (promediando por total de hilos)
# ===============================
df["total_hilos"] = df["procesos"] * df["hilos"]
df_mean = df.groupby(["muestras", "total_hilos"]).mean(numeric_only=True).reset_index()

for th in sorted(df_mean["total_hilos"].unique()):
    subset = df_mean[df_mean["total_hilos"] == th]
    plt.plot(subset["muestras"], subset["diferencia_pi"], marker="o", label=f"{th} hilos totales")

plt.title("Error Absoluto en π vs muestras")
plt.xlabel("Número de muestras")
plt.ylabel("Error absoluto en π")
plt.xscale("log")
plt.yscale("log")
plt.legend()
plt.grid(True)
plt.savefig(f"{output_dir}/error_pi_vs_muestras.png")
plt.clf()

print(f"✅ Gráficas generadas en la carpeta '{output_dir}'")
