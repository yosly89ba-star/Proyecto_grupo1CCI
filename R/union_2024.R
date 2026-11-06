library(readr)
library(dplyr)

anio    <- 2024
carpeta <- file.path("data/raw", anio)

# Función para leer cada archivo como texto y quitar espacios
leer <- function(archivo, columnas) {
  read_csv(file.path(carpeta, paste0(archivo, "_", anio, ".csv")),
           col_types = cols(.default = col_character()),
           col_select = all_of(columnas), progress = FALSE) |>
    mutate(across(everything(), trimws))
}

# 1. Leer los 7 archivos
rech6  <- leer("RECH6",  c("HHID", "HC0", "HC60", "HC1", "HC27", "HC2", "HC3", "HC53",
                           "HC55", "HC56", "HC56A", "HC57", "HC57A", "HC70", "HC71",
                           "HC72", "HC73", "HC61", "HC63", "HC64"))
rech5  <- leer("RECH5",  c("HHID", "HA0", "HA1", "HA40", "HA53", "HA54", "HA56", "HA57"))
rec44  <- leer("REC44",  c("CASEID", "HWIDX", "HW1", "HW2", "HW3", "HW53"))
rec43  <- leer("REC43",  c("CASEID", "HIDX", "H11", "H22"))
rec95  <- leer("REC95",  c("CASEID", "IDX95", "S465EA", "S465EC", "S465ED", "S466"))
rech0  <- leer("RECH0",  c("HHID", "HV001", "HV022", "HV005", "HV024", "HV025",
                           "HV040", "HV009", "HV014", "UBIGEO"))
rech23 <- leer("RECH23", c("HHID", "HV270", "HV201", "HV205", "HV226"))

# 2. Preparar REC44 (puente entre el niño y su madre)
rec44 <- rec44 |>
  mutate(HHID = trimws(substr(CASEID, 1, nchar(CASEID) - 3)),
         HC60 = trimws(substr(CASEID, nchar(CASEID) - 2, nchar(CASEID)))) |>
  rename(HC1 = HW1, HC2 = HW2, HC3 = HW3, HC53 = HW53) |>
  distinct(HHID, HC60, HC1, HC2, HC3, HC53, .keep_all = TRUE)

# 3. Unir los 7 archivos
df24 <- rech6 |>
  left_join(rec44,  by = c("HHID", "HC60", "HC1", "HC2", "HC3", "HC53")) |>
  left_join(rec43,  by = c("CASEID", "HWIDX" = "HIDX")) |>
  left_join(rec95,  by = c("CASEID", "HWIDX" = "IDX95")) |>
  left_join(rech5,  by = c("HHID", "HC60" = "HA0")) |>
  left_join(rech0,  by = "HHID") |>
  left_join(rech23, by = "HHID")

# 4. Marcar el año
df24$anio <- anio

# 5. Verificar
cat("Filas RECH6:", nrow(rech6), "| filas df24:", nrow(df24), "| columnas:", ncol(df24), "\n")

# 6. Guardar
write_csv(df24, "datos_2024.csv", na = "")

