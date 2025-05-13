import pandas as pd
import matplotlib.pyplot as plt
import os

script_dir = os.path.dirname(__file__)

os.chdir(script_dir)

# Crear carpeta de salida si no existe
output_dir = "graficasMPI"
os.makedirs(output_dir, exist_ok=True)

# Leer el CSV generado por benchmarkMPI.sh
df = pd.read_csv("resultados_MPI.csv")

# Convertimos a los tipos correctos
df["num_steps"] = df["num_steps"].astype(int)
df["num_procs"] = df["num_procs"].astype(int)
df["serial_time"] = df["serial_time"].astype(float)
df["parallel_time"] = df["parallel_time"].astype(float)
df["speedup"] = df["speedup"].astype(float)
df["diff_pi"] = df["diff_pi"].astype(float)

# Lista fija de procesos que quieres mostrar
procesos_validos = [1, 2, 4, 8, 16, 20]

# ================================
# 1. Speedup vs. número de procesos
# ================================
for steps in sorted(df["num_steps"].unique()):
    subset = df[df["num_steps"] == steps]
    plt.plot(subset["num_procs"], subset["speedup"], marker="o", label=f"{steps} pasos")

plt.title("Speedup vs Número de Procesos (MPI)")
plt.xlabel("Número de procesos")
plt.ylabel("Speedup")
plt.xticks(procesos_validos)  # <-- usar SOLO los procesos que definiste
plt.legend()
plt.grid(True)
plt.savefig(f"{output_dir}/speedup_vs_procesos.png")
plt.clf()

# ================================
# 2. Tiempo paralelo vs número de pasos (por cantidad de procesos)
# ================================
for procs in sorted(df["num_procs"].unique()):
    if procs in procesos_validos:
        subset = df[df["num_procs"] == procs]
        plt.plot(subset["num_steps"], subset["parallel_time"], marker="s", label=f"{procs} procesos")

plt.title("Tiempo paralelo vs Número de pasos (MPI)")
plt.xlabel("Número de pasos")
plt.ylabel("Tiempo paralelo (s)")
plt.legend()
plt.grid(True)
plt.xscale("log")
plt.yscale("log")
plt.savefig(f"{output_dir}/tiempo_vs_pasos.png")
plt.clf()

# ================================
# 3. Error absoluto en π vs número de pasos
# ================================
for procs in sorted(df["num_procs"].unique()):
    if procs in procesos_validos:
        subset = df[df["num_procs"] == procs]
        plt.plot(subset["num_steps"], subset["diff_pi"], marker="^", label=f"{procs} procesos")

plt.title("Error absoluto en π vs Número de pasos (MPI)")
plt.xlabel("Número de pasos")
plt.ylabel("Error absoluto en π")
plt.legend()
plt.grid(True)
plt.xscale("log")
plt.yscale("log")
plt.savefig(f"{output_dir}/error_pi_vs_pasos.png")
plt.clf()

print(f"✅ Gráficas generadas en la carpeta '{output_dir}':")
print("- speedup_vs_procesos.png")
print("- tiempo_vs_pasos.png")
print("- error_pi_vs_pasos.png")
