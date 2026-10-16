# Análisis econométrico: datos de gapminder

Este ejercicio analiza, en R, la base `gapminder` (9.843 observaciones de distintos países entre 1960 y 2010). La **Parte 1** estudia el ingreso por persona de Argentina: ajusta tres modelos de tendencia (lineal, polinomio de grado 2 y de grado 10), los compara en un período de test y analiza la correlación del ingreso con otros cuatro países sudamericanos. La **Parte 2** estudia la esperanza de vida en 2007: la relación con la esperanza de vida femenina, un test de hipótesis, una regresión múltiple con el ingreso y un modelo explicativo propio de hasta tres variables.

## Contenido de la carpeta

    analisis_econometrico/
    |-- README.md
    |-- script_principal.R
    `-- data/
        `-- gapminder.csv

- **`script_principal.R`**: contiene todo el análisis (Parte 1 y Parte 2), paso a paso y comentado. Es el único archivo que hay que correr.
- **`data/gapminder.csv`**: la base de datos que lee el script.

No hay `funciones.R` porque en este ejercicio no se definen funciones propias.

## Cómo reproducir los resultados

1. Abrir R o RStudio.
2. Instalar el paquete, una sola vez:

        install.packages("tidyverse")

3. Fijar como directorio de trabajo esta carpeta. En RStudio: abrir `script_principal.R` y usar *Session → Set Working Directory → To Source File Location*. Así el script encuentra `data/gapminder.csv`.
4. Correr `script_principal.R` completo (botón *Source*).

El script empieza con `set.seed(123)`. Este análisis no usa números aleatorios, así que los resultados son siempre los mismos.

## Datos

| Variable | Descripción |
|---|---|
| `country` | País |
| `year` | Año (1960 a 2010) |
| `income_per_person` | Ingreso por persona |
| `life_expectancy` | Esperanza de vida total (años) |
| `life_expectancy_female` | Esperanza de vida de las mujeres (años) |
| `child_mortality` | Mortalidad infantil (muertes de menores de 5 años cada 1.000 nacidos) |
| `world_region` | Región del mundo (6 regiones) |

Argentina tiene datos de ingreso completos para los 51 años. En 2007, `life_expectancy_female` viene como texto y sus datos faltantes figuran como "-": la convertimos a número y sacamos esos casos, por lo que la Parte 2 trabaja con 184 países.

## Decisiones de diseño

- **Train y test.** En la Parte 1 usamos 1960–2000 (41 años) para estimar los modelos y dejamos 2001–2010 (10 años) para testear. El tiempo se mide como `t = year - 1960`.
- **Polinomios.** El de grado 2 usa `poly(t, 2, raw = TRUE)` para que los coeficientes se lean directo. El de grado 10 usa `poly(t, 10)` (polinomios ortogonales), porque t^10 da números gigantes y la estimación se vuelve inestable; las predicciones son las mismas.
- **Escala logarítmica en el gráfico de los tres modelos**, porque el grado 10 se dispara en el test y, si no, el gráfico queda ilegible.
- **Correlaciones en niveles y en crecimiento.** Para el inciso 3 elegimos Argentina, Brasil, Chile, Uruguay y Colombia. El crecimiento interanual se calcula dentro de cada país; 1960 queda sin dato porque no tiene año anterior.
- **Test de hipótesis.** Comparamos, país por país, la esperanza de vida femenina con la total. El estadístico t se compara con 1,65 (test unilateral al 5%).
- **Ingreso en logaritmo.** En los incisos 8 y 9 usamos `log(income_per_person)`, porque el ingreso mejora mucho la esperanza de vida en países pobres y cada vez menos en países ricos.
- **Modelo propio (inciso 9).** Dejamos afuera la esperanza de vida femenina y masculina, porque forman parte de la esperanza de vida total y la explicarían de forma mecánica. Agregamos las variables de a una y miramos cuánto sube el R².

## Resumen de resultados

**Parte 1: ingreso por persona en Argentina**

- **Inciso 1:** el ingreso casi se duplica entre 1960 (unos 9.800) y 2010 (unos 18.900), con caídas en los 80 y en la crisis de 2001–2002.
- **Inciso 2:**

  | Modelo | R² | RMSE train | RMSE test |
  |---|---|---|---|
  | Lineal | 0,45 | 1.213 | 2.012 |
  | Grado 2 | 0,50 | 1.160 | 3.114 |
  | Grado 10 | 0,94 | 393 | 138.837 |

  El grado 10 tiene el menor error en train pero el mayor en test: sobreajusta. El lineal es el que mejor predice 2001–2010.
- **Inciso 3:** en niveles, las correlaciones son altas (0,77 a 0,96) porque los cinco países crecen a lo largo del tiempo. En crecimiento interanual son mucho más bajas (0,01 a 0,57). En los dos casos, Uruguay es el país más parecido a Argentina (0,83 y 0,51) y Chile el menos (0,77 y 0,17).

**Parte 2: esperanza de vida en 2007**

- **Inciso 5:** casi todos los países están por debajo de la línea de 45°: las mujeres viven más que el promedio.
- **Inciso 6:** esperanza de vida = 6,91 + 0,88 × esperanza de vida femenina (R² = 0,937).
- **Inciso 7:** las mujeres viven en promedio 1,5 años más que el total. Como t = 7,95 > 1,65, rechazamos H0: la esperanza de vida femenina es mayor que la total.
- **Inciso 8:** al agregar el logaritmo del ingreso, su coeficiente es positivo y significativo (0,55, p = 0,01), pero el R² casi no cambia (de 0,937 a 0,939).
- **Inciso 9:** el modelo con log del ingreso, mortalidad infantil y región explica el 82% de la esperanza de vida (el ingreso solo, 61%; con mortalidad infantil, 80%). A mayor ingreso, mayor esperanza de vida; a mayor mortalidad infantil, menor. Comparadas con América, África subsahariana (−5,2 años) y Asia oriental y Pacífico (−2,5 años) tienen menor esperanza de vida.

La interpretación completa de cada inciso está en `informe.pdf`.
