# =====================================================================
# Simulación 2: ataque en el juego TEG
# Script principal. Las funciones están en funciones.R
# (correr con el directorio de trabajo = carpeta de este script)
# =====================================================================

set.seed(123)               # reproducibilidad: SIEMPRE al principio
source("funciones.R")       # carga resultado_ataque, simular_batalla, etc.

# ---------------------------------------------------------------------
# Inciso 1: resultado_ataque
# ---------------------------------------------------------------------

# Paso 1: ejemplos con distinta cantidad de dados
# Devuelve cuántas fichas pierde cada jugador en una tirada.
print(resultado_ataque(3, 3))   # atacante con 3 dados, defensor con 3
print(resultado_ataque(3, 2))
print(resultado_ataque(1, 1))

# ---------------------------------------------------------------------
# Inciso 2: simular_batalla
# ---------------------------------------------------------------------

# Paso 1: ejemplos de batallas completas
# Devuelve fichas restantes de cada uno y conquista (1 = conquistó).
print(simular_batalla(5, 5))
print(simular_batalla(10, 3))
print(simular_batalla(2, 5))

# ---------------------------------------------------------------------
# Inciso 3: probabilidad_ataque
# ---------------------------------------------------------------------

# Paso 1: probabilidad de conquistar con 5 fichas contra 5 (1000 batallas)
prob_5_vs_5 <- probabilidad_ataque(1000, 5, 5)
print(prob_5_vs_5)

# Paso 2: error estándar de la estimación (para saber cuánto confiar en
# el número): sqrt(p * (1 - p) / n)
sqrt(prob_5_vs_5 * (1 - prob_5_vs_5) / 1000)