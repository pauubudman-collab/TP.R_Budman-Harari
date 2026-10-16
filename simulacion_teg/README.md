# Simulación 2: ataque en el juego TEG

Este ejercicio simula, en R, el proceso de ataque del juego TEG: una tirada de dados, una batalla completa y la estimación de la probabilidad de que el atacante conquiste un territorio.

## Contenido de la carpeta

    simulacion_teg/
    |-- README.md
    |-- script_principal.R
    `-- funciones.R

- **`script_principal.R`**: resuelve los incisos 1 a 3 paso a paso, con ejemplos y la estimación final. Es el único archivo que hay que correr.
- **`funciones.R`**: contiene solo las definiciones de las funciones. El script principal las carga con `source("funciones.R")`.

No se usan datos externos: todo se genera por simulación, así que no hay carpeta `data/`.

## Cómo reproducir los resultados

1. Abrir R o RStudio.
2. Fijar como directorio de trabajo esta carpeta. En RStudio: abrir `script_principal.R` y usar *Session → Set Working Directory → To Source File Location*.
3. Correr `script_principal.R` completo (botón *Source*).

No hace falta instalar ningún paquete. El script empieza con `set.seed(123)`, así que los resultados son reproducibles.

## Reglas del juego que se implementan

- El atacante tira entre 1 y 3 dados, pero como máximo sus fichas menos 1, porque siempre debe dejar una ficha en su país. El defensor tira entre 1 y 3 dados, como máximo sus fichas.
- Los dados de cada jugador se ordenan de mayor a menor y se comparan par a par. Se comparan tantos pares como dados tenga quien tira menos.
- En cada par pierde una ficha el perdedor. En caso de empate gana el defensor.
- La batalla continúa mientras el atacante tenga más de 1 ficha y el defensor tenga al menos 1.

## Funciones (`funciones.R`)

| Función | Qué hace |
|---|---|
| `resultado_ataque(dados_atacante, dados_defensor)` | Simula una tirada: devuelve un vector con las fichas que pierden el atacante y el defensor (inciso 1). Verifica que cada jugador tire entre 1 y 3 dados. |
| `simular_batalla(fichas_atacante, fichas_defensor)` | Simula una batalla completa y devuelve las fichas finales de cada uno y un indicador de conquista (1 si el defensor se quedó sin fichas, 0 si no) (inciso 2). |
| `probabilidad_ataque(n_batallas = 1000, fichas_atacante = 5, fichas_defensor = 5)` | Simula `n_batallas` batallas y estima la probabilidad de conquista como la proporción de batallas ganadas por el atacante (inciso 3). Por defecto usa los valores de la consigna. |

## Resultados principales

- **Inciso 1:** con `set.seed(123)`, `resultado_ataque(3, 3)` da 1 ficha perdida para el atacante y 2 para el defensor; `resultado_ataque(3, 2)` da 2 y 0; y `resultado_ataque(1, 1)` da 1 y 0. En cada tirada, las fichas perdidas suman la cantidad de pares comparados.
- **Inciso 2:** `simular_batalla(10, 3)` termina con conquista y 8 fichas para el atacante; `simular_batalla(2, 5)` termina sin conquista, con el atacante en 1 ficha y el defensor intacto.
- **Inciso 3:** con 5 fichas contra 5 y 1000 batallas, la probabilidad estimada de que el atacante conquiste es **0,189**, con un error estándar de aproximadamente 0,012 (intervalo de confianza aproximado del 95%: [0,165; 0,213]). El atacante parte en desventaja porque siempre debe dejar una ficha en su país y porque los empates favorecen al defensor.

La explicación de cada inciso está en `informe.pdf`.
