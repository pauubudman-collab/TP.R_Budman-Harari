# =====================================================================
# funciones.R  --  Simulación 2: ataque en el juego TEG
# Acá SOLO se definen funciones. No se ejecuta nada (eso va en
# script_principal.R, que las llama con source()).
# =====================================================================

# ---------------------------------------------------------------------
# Inciso 1: resultado_ataque
# ---------------------------------------------------------------------
# Tira los dados del atacante y del defensor, los ordena de mayor a menor,
# compara par a par y devuelve cuántas fichas pierde cada uno.
# Regla del TEG: en caso de empate gana el defensor.
resultado_ataque <- function(dados_atacante, dados_defensor) {
  # chequeos de robustez
  if (dados_atacante < 1 || dados_atacante > 3) stop("El atacante tira entre 1 y 3 dados")
  if (dados_defensor < 1 || dados_defensor > 3) stop("El defensor tira entre 1 y 3 dados")
  
  # cada dado es un número al azar entre 1 y 6 (se ordenan de mayor a menor)
  atacante <- sort(sample(1:6, dados_atacante, replace = TRUE), decreasing = TRUE)
  defensor <- sort(sample(1:6, dados_defensor, replace = TRUE), decreasing = TRUE)
  
  # se comparan tantos pares como el menor número de dados
  comparaciones <- min(dados_atacante, dados_defensor)
  
  pierde_atacante <- 0
  pierde_defensor <- 0
  for (i in 1:comparaciones) {
    if (atacante[i] > defensor[i]) {
      pierde_defensor <- pierde_defensor + 1
    } else {
      pierde_atacante <- pierde_atacante + 1   # empate: gana el defensor
    }
  }
  
  return(c(atacante = pierde_atacante, defensor = pierde_defensor))
}

# ---------------------------------------------------------------------
# Inciso 2: simular_batalla
# ---------------------------------------------------------------------
# El atacante ataca hasta conquistar el territorio (defensor sin fichas)
# o hasta quedarse con 1 ficha (en el TEG siempre deja 1 en su país).
# Dados: el atacante tira hasta 3, pero como máximo sus fichas menos 1.
#        El defensor tira hasta 3, como máximo sus fichas.
# Devuelve las fichas que le quedan a cada uno y si hubo conquista (1/0).
simular_batalla <- function(fichas_atacante, fichas_defensor) {
  if (fichas_atacante < 1 || fichas_defensor < 1) stop("Ambos necesitan al menos 1 ficha")
  
  atacante <- fichas_atacante
  defensor <- fichas_defensor
  
  # mientras el atacante pueda atacar y el defensor tenga fichas
  while (atacante > 1 && defensor > 0) {
    dados_atacante <- min(3, atacante - 1)
    dados_defensor <- min(3, defensor)
    
    perdidas <- resultado_ataque(dados_atacante, dados_defensor)
    
    atacante <- atacante - perdidas[["atacante"]]
    defensor <- defensor - perdidas[["defensor"]]
  }
  
  return(c(atacante = atacante, defensor = defensor,
           conquista = as.numeric(defensor == 0)))
}

# ---------------------------------------------------------------------
# Inciso 3: probabilidad_ataque
# ---------------------------------------------------------------------
# Simula muchas batallas y calcula en qué proporción de ellas el
# atacante conquista el territorio (estimación de la probabilidad).
# Por defecto: 1000 batallas, 5 fichas contra 5 (lo que pide la consigna).
probabilidad_ataque <- function(n_batallas = 1000, fichas_atacante = 5,
                                fichas_defensor = 5) {
  conquistas <- numeric(n_batallas)
  for (i in 1:n_batallas) {
    resultado <- simular_batalla(fichas_atacante, fichas_defensor)
    conquistas[i] <- resultado[["conquista"]]   # 1 si conquistó, 0 si no
  }
  
  # la proporción de batallas ganadas estima la probabilidad
  return(mean(conquistas))
}