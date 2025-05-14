import pandas as pd
import matplotlib.pyplot as plt
import os

# ================================
# Configuración y lectura de CSV
# ================================
df = pd.read_csv("resultados_CUDA.csv")

df["Puntos"] = df["Puntos"].astype(int)
df["Tiempo(s)"] = df["Tiempo(s)"].astype(float)
df["Pi"] = df["Pi"].astype(float)
df["Metodo"] = df["Metodo"].astype(str)
df["Aceleracion"] = pd.to_numeric(df["Aceleracion"], errors='coerce')  # N/A se vuelve NaN

output_dir = "graficasCUDA"
os.makedirs(output_dir, exist_ok=True)

# Separar datos por método
df_cuda = df[df["Metodo"] == "CUDA"]
df_seq = df[df["Metodo"] == "Secuencial"]

# ================================
# 1. Aceleración vs Número de Puntos (CUDA)
# ================================
plt.plot(df_cuda["Puntos"], df_cuda["Aceleracion"], label="Aceleración (CUDA)", marker='o', color='blue')
plt.title("Aceleración vs Número de Puntos (CUDA)")
plt.xlabel("Número de Puntos")
plt.ylabel("Aceleración")
plt.grid(True)
plt.xscale("log")
plt.savefig(f"{output_dir}/aceleracion_vs_puntos.png")
plt.clf()

# ================================
# 2. Error Absoluto en π vs Número de Puntos
# ================================
PI_REAL = 3.141592653589793
plt.plot(df_cuda["Puntos"], abs(df_cuda["Pi"] - PI_REAL), label="CUDA", marker='o', color='green')
plt.plot(df_seq["Puntos"], abs(df_seq["Pi"] - PI_REAL), label="Secuencial", marker='x', color='red')
plt.title("Error Absoluto en π vs Número de Puntos")
plt.xlabel("Número de Puntos")
plt.ylabel("Error Absoluto en π")
plt.legend()
plt.grid(True)
plt.xscale("log")
plt.yscale("log")
plt.savefig(f"{output_dir}/error_pi_vs_puntos.png")
plt.clf()

# ================================
# 3. Valor estimado de π vs Número de Puntos
# ================================
plt.plot(df_cuda["Puntos"], df_cuda["Pi"], label="CUDA", marker='o', color='blue')
plt.plot(df_seq["Puntos"], df_seq["Pi"], label="Secuencial", marker='x', color='orange')
plt.axhline(y=PI_REAL, color='black', linestyle='--', label="π Real")
plt.title("Valor Estimado de π vs Número de Puntos")
plt.xlabel("Número de Puntos")
plt.ylabel("Valor Estimado de π")
plt.legend()
plt.grid(True)
plt.xscale("log")
plt.savefig(f"{output_dir}/valor_pi_vs_puntos.png")
plt.clf()

# ================================
# Finalización
# ================================
print(f"✅ Gráficas generadas en la carpeta '{output_dir}':")
print("- aceleracion_vs_puntos.png")
print("- error_pi_vs_puntos.png")
print("- valor_pi_vs_puntos.png")
