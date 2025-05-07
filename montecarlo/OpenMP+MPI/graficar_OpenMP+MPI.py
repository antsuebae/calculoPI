import pandas as pd
import matplotlib.pyplot as plt
import os

# Configurar salida
output_dir = "graficasOpenMP+MPI"
os.makedirs(output_dir, exist_ok=True)

# Leer datos
df = pd.read_csv("resultados_OpenMP+MPI.csv")

# Conversión de tipos
df["pasos"] = df["pasos"].astype(int)
df["procesos"] = df["procesos"].astype(int)
df["hilos"] = df["hilos"].astype(int)
df["tiempo_paralelo"] = df["tiempo_paralelo"].astype(float)
df["speedup"] = df["speedup"].astype(float)
df["diferencia_pi"] = df["diferencia_pi"].astype(float)

# ===============================
# 1. Heatmap de tiempo de ejecución por procesos y hilos (para cada pasos)
# ===============================
for pasos in sorted(df["pasos"].unique()):
    pivot = df[df["pasos"] == pasos].pivot(index="procesos", columns="hilos", values="tiempo_paralelo")
    plt.figure(figsize=(10, 6))
    plt.imshow(pivot, cmap="YlGnBu", aspect='auto', interpolation="nearest")
    plt.colorbar(label="Tiempo (s)")
    plt.title(f"Tiempo Paralelo (s) - {pasos} pasos")
    plt.xlabel("Hilos")
    plt.ylabel("Procesos")
    plt.xticks(range(len(pivot.columns)), pivot.columns)
    plt.yticks(range(len(pivot.index)), pivot.index)
    plt.savefig(f"{output_dir}/heatmap_tiempo_{pasos}_pasos.png")
    plt.clf()

# ===============================
# 2. Heatmap de speedup por procesos y hilos (para cada pasos)
# ===============================
for pasos in sorted(df["pasos"].unique()):
    pivot = df[df["pasos"] == pasos].pivot(index="procesos", columns="hilos", values="speedup")
    plt.figure(figsize=(10, 6))
    plt.imshow(pivot, cmap="YlOrRd", aspect='auto', interpolation="nearest")
    plt.colorbar(label="Speedup")
    plt.title(f"Speedup - {pasos} pasos")
    plt.xlabel("Hilos")
    plt.ylabel("Procesos")
    plt.xticks(range(len(pivot.columns)), pivot.columns)
    plt.yticks(range(len(pivot.index)), pivot.index)
    plt.savefig(f"{output_dir}/heatmap_speedup_{pasos}_pasos.png")
    plt.clf()

# ===============================
# 3. Error en pi vs pasos (promediando por total de hilos)
# ===============================
df["total_hilos"] = df["procesos"] * df["hilos"]
df_mean = df.groupby(["pasos", "total_hilos"]).mean(numeric_only=True).reset_index()

for th in sorted(df_mean["total_hilos"].unique()):
    subset = df_mean[df_mean["total_hilos"] == th]
    plt.plot(subset["pasos"], subset["diferencia_pi"], marker="o", label=f"{th} hilos totales")

plt.title("Error Absoluto en π vs Pasos")
plt.xlabel("Número de pasos")
plt.ylabel("Error absoluto en π")
plt.xscale("log")
plt.yscale("log")
plt.legend()
plt.grid(True)
plt.savefig(f"{output_dir}/error_pi_vs_pasos.png")
plt.clf()

print(f"✅ Gráficas generadas en la carpeta '{output_dir}'")
