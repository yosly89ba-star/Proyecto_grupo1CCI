library(readr)
library(dplyr)

# 1. Leer los dos datasets (todo como texto, igual que al unirlos)
df24 <- read_csv("data/processed/datos_2024.csv",
                 col_types = cols(.default = col_character()))
df25 <- read_csv("data/processed/datos_2025.csv",
                 col_types = cols(.default = col_character()))

# 2. Verificar que las columnas coincidan (vacío = coinciden)
diferencias <- symdiff(names(df24), names(df25))
print(diferencias)
stopifnot("Las columnas de 2024 y 2025 no coinciden" = length(diferencias) == 0)

# 3. Unir (apilar un año debajo del otro)
df <- bind_rows(df24, df25)

# 4. Verificar que el total sea la suma
cat(nrow(df24), nrow(df25), nrow(df), "\n")
stopifnot("El total no es la suma" = nrow(df) == nrow(df24) + nrow(df25))
stopifnot("Hay niños repetidos" = !any(duplicated(df[c("anio", "HHID", "HC0")])))
print(table(df$anio))

# 5. Guardar
write_csv(df, "data/processed/datos_2024_2025.csv", na = "")
