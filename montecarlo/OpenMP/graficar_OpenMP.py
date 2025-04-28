import pandas as pd
import matplotlib.pyplot as plt
import os

# Crear carpeta si no existe
output_dir = "graficasOpenMP"
os.makedirs("graficasOpenMP", exist_ok=True)

# Leer el CSV generado por benchmark_pi_montecarlo.sh
df = pd.read_csv("resultados_OpenMP.csv")

# Convertimos tipos por seguridad
df["muestras"] = df["muestras"].astype(int)
df["hilos"] = df["hilos"].astype(int)
df["tiempo_paralelo"] = df["tiempo_paralelo"].astype(float)
df["speedup"] = df["speedup"].astype(float)
df["diferencia_pi"] = df["diferencia_pi"].astype(float)

# Lista fija de número de hilos usados
hilos_validos = sorted(df["hilos"].unique())

# ================================
# 1. Speedup vs. hilos por cantidad de muestras
# ================================
for muestras in sorted(df["muestras"].unique()):
    subset = df[df["muestras"] == muestras]
    plt.plot(subset["hilos"], subset["speedup"], marker="o", label=f"{muestras} muestras")

plt.title("Speedup vs Número de Hilos")
plt.xlabel("Número de hilos")
plt.ylabel("Speedup")
plt.xticks(hilos_validos)  # <-- aquí forzamos que solo aparezcan tus hilos válidos
plt.legend()
plt.grid(True)
plt.savefig(f"{output_dir}/speedup_vs_hilos.png")
plt.clf()

# ================================
# 2. Tiempo paralelo vs muestras por número de hilos
# ================================
for hilos in sorted(df["hilos"].unique()):
    subset = df[df["hilos"] == hilos]
    plt.plot(subset["muestras"], subset["tiempo_paralelo"], marker="s", label=f"{hilos} hilos")

plt.title("Tiempo paralelo vs Número de muestras")
plt.xlabel("Número de muestras")
plt.ylabel("Tiempo (s)")
plt.legend()
plt.grid(True)
plt.xscale("log")
plt.yscale("log")
plt.savefig(f"{output_dir}/tiempo_vs_pasos.png")
plt.clf()

# ================================
# 3. Error absoluto en π vs muestras
# ================================
for hilos in sorted(df["hilos"].unique()):
    subset = df[df["hilos"] == hilos]
    plt.plot(subset["muestras"], subset["diferencia_pi"], marker="^", label=f"{hilos} hilos")

plt.title("Error absoluto en π vs Número de muestras")
plt.xlabel("Número de muestras")
plt.ylabel("Error absoluto")
plt.legend()
plt.grid(True)
plt.xscale("log")
plt.yscale("log")
plt.savefig(f"{output_dir}/error_pi_vs_pasos.png")
plt.clf()

print(f"✅ Gráficas generadas en la carpeta '{output_dir}':")
print("- speedup_vs_hilos.png")
print("- tiempo_vs_pasos.png")
print("- error_pi_vs_pasos.png")

