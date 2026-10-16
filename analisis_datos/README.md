# Análisis de datos: vuelos de Nueva York

Este ejercicio analiza, en R, las bases `flights` y `weather` del paquete `nycflights13` (336.776 vuelos que salieron de los aeropuertos JFK, LaGuardia y Newark en 2013, y el clima por hora en cada aeropuerto). Responde tres preguntas sobre la relación entre el viento y las demoras dentro de un mismo mes, el porcentaje de vuelos que cancela cada aerolínea y la época del año en que salen más vuelos.

## Contenido de la carpeta

    analisis_datos/
    |-- README.md
    `-- script_principal.R

- **`script_principal.R`**: contiene todo el análisis (exploración de los datos y las tres preguntas), paso a paso y comentado. Es el único archivo que hay que correr.

No hay `funciones.R` porque en este ejercicio no se definen funciones propias. Tampoco hay carpeta `data/`: los datos vienen incluidos en el paquete `nycflights13`.

## Cómo reproducir los resultados

1. Abrir R o RStudio.
2. Instalar los paquetes, una sola vez:

        install.packages("tidyverse")
        install.packages("nycflights13")

3. Fijar como directorio de trabajo esta carpeta. En RStudio: abrir `script_principal.R` y usar *Session → Set Working Directory → To Source File Location*.
4. Correr `script_principal.R` completo (botón *Source*).

El script empieza con `set.seed(123)`. Este análisis no usa números aleatorios, así que los resultados son siempre los mismos.

## Datos

| Base | Variable | Descripción |
|---|---|---|
| `flights` | `month`, `day` | Mes y día del vuelo |
| `flights` | `dep_delay` | Demora en la salida (minutos; negativo = salió antes) |
| `flights` | `dep_time` | Hora real de salida (vacía si el vuelo se canceló) |
| `flights` | `carrier` | Código de la aerolínea |
| `weather` | `month`, `day` | Mes y día de la medición |
| `weather` | `wind_speed` | Velocidad del viento (mph) |

La base `flights` tiene 336.776 vuelos, de los cuales 8.255 no tienen demora registrada porque fueron cancelados. La base `weather` tiene 26.115 mediciones por hora, con 4 datos de viento faltantes y un valor de 1.048 mph, que es un error de carga.

## Decisiones de diseño

- **Un dato por día.** Para la pregunta 1 calculamos la demora promedio y el viento promedio de cada día, para poder unir las dos bases. A la base de clima le falta un día, así que trabajamos con 364 días.
- **Se excluye el error de viento.** El valor de 1.048 mph es imposible, así que usamos solo vientos menores a 100 mph.
- **Comparación dentro de cada mes.** Como el viento y las demoras podrían depender de la época del año, en la pregunta 1 comparamos cada día con el promedio de su mes, y así ese efecto queda afuera.
- **Porcentajes, no cantidades.** En la pregunta 2 comparamos el porcentaje de vuelos cancelados, para no castigar a las aerolíneas que tienen más vuelos.
- **Vuelos por día, no por mes.** En la pregunta 3 dividimos los vuelos de cada mes por su cantidad de días, porque los meses no tienen todos la misma duración.

## Resumen de resultados

- **Datos:** 336.776 vuelos, 8.255 cancelados. La demora va de −43 a 1.301 minutos, y la mayoría de los vuelos sale a horario o con poca demora.
- **Pregunta 1:** con todos los días juntos, cada mph más de viento suma 0,36 minutos de demora (R² = 0,01). Comparando dentro de cada mes, el efecto es mayor: 0,47 minutos por mph (p-valor = 0,006, R² = 0,02). Los meses con más viento (febrero y marzo) no son los de más demora (junio y julio), así que la época del año no explica la relación. El efecto es significativo pero chico.
- **Pregunta 2:** las aerolíneas que más cancelan son OO y YV (9%), seguidas por 9E y EV (5–6%). La mayoría cancela menos del 3%, y HA no canceló ningún vuelo. OO tiene solo 32 vuelos, así que su porcentaje es poco confiable.
- **Pregunta 3:** los meses con más vuelos por día son julio y agosto (unos 950) y los de menos, enero (871) y febrero (891). La diferencia es de unos 80 vuelos por día (cerca de un 9%).

La interpretación completa de cada pregunta está en `informe.pdf`.
