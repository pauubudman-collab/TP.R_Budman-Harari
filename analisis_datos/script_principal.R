# Ejercicio de Análisis de datos:nycflights13
# Script principal. No se definen funciones propias, por eso no hay
# archivo funciones.R en esta carpeta.

#Introducción al ejercicio 1

rm(list = ls())
set.seed(123)
library(tidyverse)
library(nycflights13)

vuelos <- flights
clima  <- weather


# Exploración ------------------------------------------------

nrow(vuelos)

# NAs = vuelos cancelados
vuelos %>%
  summarise(
    NA_dep_delay = sum(is.na(dep_delay)),
    demora_min   = min(dep_delay, na.rm = TRUE),
    demora_max   = max(dep_delay, na.rm = TRUE)
  )

ggplot(vuelos %>% filter(!is.na(dep_delay)), aes(x = dep_delay)) +
  geom_histogram(binwidth = 10, fill = "steelblue") +
  labs(title = "Demora de salida", x = "Minutos", y = "Vuelos") +
  theme_minimal()

# Viento: un valor de más de 1000 mph es un error de carga
clima %>% summarise(NA_viento = sum(is.na(wind_speed)), viento_max = max(wind_speed, na.rm = TRUE))
clima %>% filter(wind_speed > 100)


# Pregunta 1 -------------------------------------------------
# Un dato por día en cada tabla para poder unirlas

demora_diaria <- vuelos %>%
  filter(!is.na(dep_delay)) %>%
  group_by(month, day) %>%
  summarise(demora = mean(dep_delay), .groups = "drop") %>%
  mutate(fecha = paste(month, day, sep = "-"))

viento_diario <- clima %>%
  filter(!is.na(wind_speed) & wind_speed < 100) %>%
  group_by(month, day) %>%
  summarise(viento = mean(wind_speed), .groups = "drop") %>%
  mutate(fecha = paste(month, day, sep = "-"))

# A clima le falta un día
demora_diaria <- demora_diaria %>% filter(fecha %in% viento_diario$fecha)
sum(demora_diaria$fecha == viento_diario$fecha)   # debe ser igual a nrow

dias <- data.frame(demora = demora_diaria$demora, viento = viento_diario$viento)

modelo <- lm(demora ~ viento, data = dias)
coef(modelo)
summary(modelo)$r.squared

ggplot(dias, aes(x = viento, y = demora)) +
  geom_point(alpha = 0.6) +
  geom_abline(intercept = coef(modelo)[1], slope = coef(modelo)[2], color = "darkred") +
  labs(title = "Viento y demora por día", x = "Viento promedio (mph)", y = "Demora promedio (min)") +
  theme_minimal()

dias$month <- demora_diaria$month

dias %>%
  group_by(month) %>%
  summarise(viento = mean(viento), demora = mean(demora))

# Comparamos cada día con el promedio de su mes, para sacar el efecto de la época del año
dias <- dias %>%
  group_by(month) %>%
  mutate(viento_mes = viento - mean(viento),
         demora_mes = demora - mean(demora))

modelo_mes <- lm(demora_mes ~ viento_mes, data = dias)
summary(modelo_mes)

ggplot(dias, aes(x = viento_mes, y = demora_mes)) +
  geom_point(alpha = 0.6) +
  geom_abline(intercept = coef(modelo_mes)[1], slope = coef(modelo_mes)[2], color = "darkred") +
  labs(x = "Viento vs. promedio del mes", y = "Demora vs. promedio del mes") +
  theme_minimal()

# Pregunta 2 -------------------------------------------------
# Porcentaje y no cantidad, para no castigar a las aerolíneas grandes

cancelaciones <- vuelos %>%
  group_by(carrier) %>%
  summarise(vuelos = length(flight), pct_cancelados = mean(is.na(dep_time)), .groups = "drop")

cancelaciones[order(cancelaciones$pct_cancelados, decreasing = TRUE), ]

ggplot(cancelaciones, aes(x = carrier, y = pct_cancelados)) +
  geom_point(size = 4, color = "steelblue") +
  scale_y_continuous(labels = scales::label_percent(accuracy = 1)) +
  labs(title = "% de vuelos cancelados por aerolínea", x = "Aerolínea", y = "% cancelados") +
  theme_minimal()


# Pregunta 3 -------------------------------------------------
# Vuelos por día de cada mes (los meses tienen distinta cantidad de días)

vuelos_mes <- vuelos %>%
  group_by(month) %>%
  summarise(vuelos = length(flight), dias = n_distinct(day), .groups = "drop") %>%
  mutate(vuelos_por_dia = vuelos / dias)

vuelos_mes[order(vuelos_mes$vuelos_por_dia, decreasing = TRUE), ]

ggplot(vuelos_mes, aes(x = month, y = vuelos_por_dia)) +
  geom_line(color = "steelblue") +
  geom_point(color = "steelblue", size = 3) +
  labs(title = "Vuelos por día según el mes", x = "Mes", y = "Vuelos por día") +
  theme_minimal()