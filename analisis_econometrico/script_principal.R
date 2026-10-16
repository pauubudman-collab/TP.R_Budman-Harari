# ============================================================
# Ejercicio 2: Análisis econométrico con datos de gapminder
# Script principal (Parte 1 y Parte 2).
# No se definen funciones propias, por eso no hay archivo
# funciones.R en esta carpeta.
# Los datos se leen desde data/gapminder.csv.
# ============================================================

#Parte 1: Ingreso por persona

#Inciso 1
rm(list = ls())
set.seed(123)        # lo pide la consigna al principio del código
library(tidyverse)

# Ruta relativa: el archivo va en la carpeta data/ del ejercicio
gapminder <- read_csv("/Users/Paulina/Downloads/gapminder.csv")

names(gapminder)     # chequear cómo se llaman las columnas


argentina <- gapminder %>%
  filter(country == "Argentina") %>%
  arrange(year)

# Chequeos antes de graficar: NAs y rango de años
sum(is.na(argentina$income_per_person))
min(argentina$year)
max(argentina$year)

ggplot(argentina, aes(x = year, y = income_per_person)) +
  geom_line(color = "steelblue", linewidth = 0.8) +
  labs(
    title = "Ingreso por persona en Argentina",
    x = "Año",
    y = "Ingreso por persona"
  ) +
  theme_minimal()

#Inciso 2

#Introduccion 

# Variable de tiempo: t = 0 en 1960
argentina <- argentina %>%
  mutate(t = year - 1960)

# Últimos 10 años para test (2001-2010); el resto para train (1960-2000)
train <- argentina %>% filter(year <= max(year) - 10)
test  <- argentina %>% filter(year >  max(year) - 10)

c(train = nrow(train), test = nrow(test))   # chequeo: 41 y 10

# (a) Modelo lineal: income = b0 + b1 * t
modelo_lineal <- lm(income_per_person ~ t, data = train)

coef(modelo_lineal)
summary(modelo_lineal)$r.squared

# Predicción y error del modelo lineal (se usan en el gráfico final)
argentina <- argentina %>%
  mutate(pred_lineal = predict(modelo_lineal, newdata = argentina))

rmse_train_lineal <- sqrt(mean((train$income_per_person - predict(modelo_lineal, newdata = train))^2))
rmse_test_lineal  <- sqrt(mean((test$income_per_person  - predict(modelo_lineal, newdata = test))^2))


# (b) Modelo polinómico de grado 2: ingreso = b0 + b1*t + b2*t^2 + error

# Estimamos el modelo SOLO con los datos de entrenamiento
# raw = TRUE para que los coeficientes sean directamente b1 (de t) y b2 (de t^2)
modelo_grado2 <- lm(income_per_person ~ poly(t, 2, raw = TRUE), data = train)
summary(modelo_grado2)

# Predicciones para todos los años (train + test)
argentina <- argentina %>%
  mutate(pred_grado2 = predict(modelo_grado2, newdata = argentina))

# Gráfico: datos observados y ajuste de grado 2
# (la línea punteada marca dónde empieza el test)
ggplot(argentina, aes(x = year)) +
  geom_point(aes(y = income_per_person)) +
  geom_line(aes(y = pred_grado2), color = "blue") +
  geom_vline(xintercept = max(train$year) + 0.5, linetype = "dashed") +
  labs(title = "Modelo polinómico de grado 2 - Argentina",
       x = "Año",
       y = "Ingreso por persona") +
  theme_minimal()

# Error en train y en test (RMSE)
rmse_train_g2 <- sqrt(mean((train$income_per_person - predict(modelo_grado2, newdata = train))^2))
rmse_test_g2  <- sqrt(mean((test$income_per_person  - predict(modelo_grado2, newdata = test))^2))

rmse_train_g2
rmse_test_g2

# (c) Modelo polinómico de grado 10: ingreso = b0 + b1*t + ... + b10*t^10 + error

# Estimamos el modelo SOLO con los datos de entrenamiento
# poly() sin raw = TRUE (como en la app Shiny de clase): con t hasta 40,
# t^10 es un número gigante y así la estimación es más estable.
# Las predicciones son las mismas.
modelo_grado10 <- lm(income_per_person ~ poly(t, 10), data = train)
summary(modelo_grado10)$r.squared

# Predicciones para todos los años (train + test)
argentina <- argentina %>%
  mutate(pred_grado10 = predict(modelo_grado10, newdata = argentina))

# Gráfico: datos observados y ajuste de grado 10
# (la línea punteada marca dónde empieza el test)
ggplot(argentina, aes(x = year)) +
  geom_point(aes(y = income_per_person)) +
  geom_line(aes(y = pred_grado10), color = "darkgreen") +
  geom_vline(xintercept = max(train$year) + 0.5, linetype = "dashed") +
  labs(title = "Modelo polinómico de grado 10 - Argentina",
       x = "Año",
       y = "Ingreso por persona") +
  theme_minimal()

# Error en train y en test (RMSE)
rmse_train_g10 <- sqrt(mean((train$income_per_person - predict(modelo_grado10, newdata = train))^2))
rmse_test_g10  <- sqrt(mean((test$income_per_person  - predict(modelo_grado10, newdata = test))^2))

rmse_train_g10
rmse_test_g10


# Gráfico con los tres modelos juntos (escala log porque el grado 10 se dispara)
ggplot(argentina, aes(x = year)) +
  geom_point(aes(y = income_per_person)) +
  geom_line(aes(y = pred_lineal,  color = "Lineal")) +
  geom_line(aes(y = pred_grado2,  color = "Grado 2")) +
  geom_line(aes(y = pred_grado10, color = "Grado 10")) +
  geom_vline(xintercept = max(train$year) + 0.5, linetype = "dashed") +
  scale_y_log10() +
  scale_color_manual(values = c("Lineal" = "red", "Grado 2" = "blue", "Grado 10" = "darkgreen")) +
  labs(title = "Tres ajustes - Argentina", x = "Año",
       y = "Ingreso por persona (escala log)", color = "Modelo") +
  theme_minimal()

# Tabla comparativa de errores
comparacion <- data.frame(
  modelo     = c("Lineal", "Grado 2", "Grado 10"),
  rmse_train = c(rmse_train_lineal, rmse_train_g2, rmse_train_g10),
  rmse_test  = c(rmse_test_lineal,  rmse_test_g2,  rmse_test_g10)
)
comparacion


# Inciso 3

# (a) Matriz de correlaciones de los ingresos
# Elegimos cuatro países sudamericanos además de Argentina
paises <- c("Argentina", "Brazil", "Chile", "Uruguay", "Colombia")

ingresos <- gapminder %>%
  filter(country %in% paises) %>%
  select(country, year, income_per_person) %>%
  arrange(country, year)

# Chequeos: que estén los 5 países, sin NAs y con los mismos años
unique(ingresos$country)
sum(is.na(ingresos$income_per_person))
ingresos %>%
  group_by(country) %>%
  summarise(anios = n_distinct(year), desde = min(year), hasta = max(year), .groups = "drop")

# Gráfico: evolución del ingreso de los cinco países
ggplot(ingresos, aes(x = year, y = income_per_person, color = country)) +
  geom_line() +
  labs(title = "Ingreso por persona", x = "Año", y = "Ingreso por persona", color = "País") +
  theme_minimal()

# Tabla con una columna por país (los años quedan ordenados igual en todos)
niveles <- data.frame(
  Argentina = ingresos$income_per_person[ingresos$country == "Argentina"],
  Brasil    = ingresos$income_per_person[ingresos$country == "Brazil"],
  Chile     = ingresos$income_per_person[ingresos$country == "Chile"],
  Uruguay   = ingresos$income_per_person[ingresos$country == "Uruguay"],
  Colombia  = ingresos$income_per_person[ingresos$country == "Colombia"]
)

# Matriz de correlaciones
round(cor(niveles), 2)


# (b) Matriz de correlaciones del crecimiento interanual (ΔY/Y)

# Crecimiento interanual: (Y_t - Y_{t-1}) / Y_{t-1}, calculado dentro de cada país
ingresos <- ingresos %>%
  group_by(country) %>%
  mutate(crecimiento = (income_per_person - lag(income_per_person)) / lag(income_per_person)) %>%
  ungroup()

# El primer año (1960) no tiene año anterior: su crecimiento queda NA y lo sacamos
crec <- ingresos %>% filter(!is.na(crecimiento))

# Gráfico: crecimiento interanual de los cinco países
ggplot(crec, aes(x = year, y = crecimiento, color = country)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_line() +
  scale_y_continuous(labels = scales::label_percent(accuracy = 1)) +
  labs(title = "Crecimiento interanual del ingreso", x = "Año", y = "Crecimiento", color = "País") +
  theme_minimal()

# Tabla con una columna por país
tasas <- data.frame(
  Argentina = crec$crecimiento[crec$country == "Argentina"],
  Brasil    = crec$crecimiento[crec$country == "Brazil"],
  Chile     = crec$crecimiento[crec$country == "Chile"],
  Uruguay   = crec$crecimiento[crec$country == "Uruguay"],
  Colombia  = crec$crecimiento[crec$country == "Colombia"]
)

# Matriz de correlaciones
round(cor(tasas), 2)


# Parte 2: Esperanza de vida y género

#Introduccion 
# ------------------------------------------------------------
# Filtrado de un año a elección: 2007
# ------------------------------------------------------------
# life_expectancy_female viene como texto: los datos faltantes figuran como "-".
# La convertimos a número; los "-" pasan a NA y los sacamos con el filtro.
gapminder_2007 <- gapminder %>%
  filter(year == 2007) %>%
  mutate(life_expectancy_female = as.numeric(life_expectancy_female)) %>%
  filter(!is.na(life_expectancy) & !is.na(life_expectancy_female))

# Chequeos: cantidad de países y rango de cada variable
nrow(gapminder_2007)
min(gapminder_2007$life_expectancy)
max(gapminder_2007$life_expectancy)
min(gapminder_2007$life_expectancy_female)
max(gapminder_2007$life_expectancy_female)

# Inciso 5: Gráfico: life_expectancy vs. life_expectancy_female
# ------------------------------------------------------------
ggplot(gapminder_2007, aes(x = life_expectancy_female, y = life_expectancy)) +
  geom_point(color = "pink", alpha = 0.7) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
  labs(
    title = "Esperanza de vida total vs. femenina (2007)",
    x = "Esperanza de vida femenina (años)",
    y = "Esperanza de vida total (años)"
  ) +
  theme_minimal()


# Inciso 6: Regresión simple: life_expectancy ~ life_expectancy_female
# ------------------------------------------------------------
modelo_simple <- lm(life_expectancy ~ life_expectancy_female, data = gapminder_2007)

summary(modelo_simple)

# Coeficientes y R2
b0_simple <- coef(modelo_simple)[1]
b1_simple <- coef(modelo_simple)[2]
r2_simple <- summary(modelo_simple)$r.squared

b0_simple
b1_simple
r2_simple

# Gráfico: datos y recta estimada
ggplot(gapminder_2007, aes(x = life_expectancy_female, y = life_expectancy)) +
  geom_point(color = "pink", alpha = 0.7) +
  geom_abline(intercept = b0_simple, slope = b1_simple, color = "darkred") +
  labs(
    title = "Regresión simple (2007)",
    x = "Esperanza de vida femenina (años)",
    y = "Esperanza de vida total (años)"
  ) +
  theme_minimal()


# Inciso 7: Contraste de hipótesis
# H0: life_expectancy_female = life_expectancy
# H1: life_expectancy_female > life_expectancy
# ------------------------------------------------------------

# Diferencia país por país (femenina - total)
gapminder_2007 <- gapminder_2007 %>%
  mutate(diferencia = life_expectancy_female - life_expectancy)

# Gráfico: distribución de las diferencias
ggplot(gapminder_2007, aes(x = diferencia)) +
  geom_histogram(binwidth = 0.5, fill = "pink", color = "white") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(title = "Diferencia entre esperanza de vida femenina y total (2007)",
       x = "Diferencia (años)", y = "Cantidad de países") +
  theme_minimal()

# Estadístico t: diferencia promedio dividida por su error estándar
n <- nrow(gapminder_2007)
media_dif <- mean(gapminder_2007$diferencia)
desvio_dif <- sd(gapminder_2007$diferencia)

t_estadistico <- media_dif / (desvio_dif / sqrt(n))

n
media_dif
t_estadistico

# Valor crítico al 5% para un test unilateral (con n grande, aprox. 1,65)
t_estadistico > 1.65

# Inciso 8: Regresión múltiple con income_per_person
# ------------------------------------------------------------
# Usamos log(income_per_person): el efecto del ingreso sobre la esperanza
# de vida es grande en países pobres y cada vez menor en países ricos.

# Chequeo: el ingreso no tiene NAs en la muestra
sum(is.na(gapminder_2007$income_per_person))

modelo_multiple <- lm(life_expectancy ~ life_expectancy_female + log(income_per_person),
                      data = gapminder_2007)

summary(modelo_multiple)

coef(modelo_multiple)

r2_multiple <- summary(modelo_multiple)$r.squared
r2_multiple

# Comparación de R2 entre modelos
c(R2_simple = r2_simple, R2_multiple = r2_multiple)

# Inciso 9: Modelo explicativo de máximo 3 covariables
# ------------------------------------------------------------

# Paso 1: exclusiones
# - life_expectancy_female y life_expectancy_male: forman parte de la esperanza
#   de vida total por construcción, la explicarían de forma mecánica.
# - country (identificador) y year (es 2007 para todos).

# Paso 2: nueva columna -> logaritmo del ingreso
# El ingreso mejora mucho la esperanza de vida en países pobres y cada vez menos
# en países ricos; el log captura esos rendimientos decrecientes.
gapminder_2007 <- gapminder_2007 %>%
  mutate(log_income = log(income_per_person))

# Chequeos de las variables que vamos a usar
sum(is.na(gapminder_2007$log_income))
sum(is.na(gapminder_2007$child_mortality))
unique(gapminder_2007$world_region)

# Paso 3: armamos el modelo agregando de a una variable y miramos el R2
modelo_9a <- lm(life_expectancy ~ log_income, data = gapminder_2007)
modelo_9b <- lm(life_expectancy ~ log_income + child_mortality, data = gapminder_2007)
modelo_9c <- lm(life_expectancy ~ log_income + child_mortality + world_region,
                data = gapminder_2007)

c(R2_ingreso    = summary(modelo_9a)$r.squared,
  R2_mortalidad = summary(modelo_9b)$r.squared,
  R2_region     = summary(modelo_9c)$r.squared)

# Paso 4: modelo propuesto
modelo_propuesto <- modelo_9c
summary(modelo_propuesto)


