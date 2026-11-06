# union_2025.R ---------------------------------------------------------------
# Une los 7 archivos de la ENDES 2025 en una sola base: una fila por niño.
# Es el mismo procedimiento usado para 2024; al final se apilarán los dos
# años con bind_rows() (equivale al pd.concat del código de la profesora).
#
# Archivos en: data/raw/2025/
#   RECH6  niño (base)       RECH5  madre       REC44  puente niño-madre
#   REC43  diarrea, fiebre   REC95  hierro, CRED
#   RECH0  hogar             RECH23 vivienda
# ---------------------------------------------------------------------------

library(readr)
library(dplyr)

anio    <- 2025
carpeta <- file.path("data/raw", anio)

# Lee un CSV del INEI como texto (para no perder ceros) y quita espacios
leer <- function(archivo, columnas) {
  read_csv(file.path(carpeta, paste0(archivo, "_", anio, ".csv")),
           col_types = cols(.default = col_character()),
           col_select = all_of(columnas), progress = FALSE) |>
    mutate(across(everything(), trimws))
}

# 1. Leer solo las variables que se usarán -----------------------------------
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

cat("RECH6:", nrow(rech6), "| RECH5:", nrow(rech5), "| REC44:", nrow(rec44),
    "| REC43:", nrow(rec43), "| REC95:", nrow(rec95),
    "| RECH0:", nrow(rech0), "| RECH23:", nrow(rech23), "\n")

# 2. Preparar el puente REC44 -------------------------------------------------
# CASEID = HHID + número de orden de la madre (últimos 3 caracteres)
rec44 <- rec44 |>
  mutate(HHID = trimws(substr(CASEID, 1, nchar(CASEID) - 3)),
         HC60 = trimws(substr(CASEID, nchar(CASEID) - 2, nchar(CASEID)))) |>
  rename(HC1 = HW1, HC2 = HW2, HC3 = HW3, HC53 = HW53) |>
  distinct(HHID, HC60, HC1, HC2, HC3, HC53, .keep_all = TRUE)

# 3. Unir (left_join: se conservan todos los niños de RECH6) -------------------
df25 <- rech6 |>
  left_join(rec44,  by = c("HHID", "HC60", "HC1", "HC2", "HC3", "HC53")) |>
  left_join(rec43,  by = c("CASEID", "HWIDX" = "HIDX")) |>
  left_join(rec95,  by = c("CASEID", "HWIDX" = "IDX95")) |>
  left_join(rech5,  by = c("HHID", "HC60" = "HA0")) |>
  left_join(rech0,  by = "HHID") |>
  left_join(rech23, by = "HHID")

# 4. Marcar el origen (como en el código de la profesora) ----------------------
df25$anio <- anio

# 5. Verificaciones ------------------------------------------------------------
cat("\nFilas RECH6:", nrow(rech6), "| filas df25:", nrow(df25), "\n")
stopifnot("La unión duplicó niños: revisar llaves" = nrow(df25) == nrow(rech6))
stopifnot("Hay niños repetidos" = !any(duplicated(df25[c("HHID", "HC0")])))
cat("Columnas:", ncol(df25), "\n")
cat("% con datos de la madre:", round(100 * mean(!is.na(df25$HA57)), 1), "\n")
cat("% con datos de salud   :", round(100 * mean(!is.na(df25$H11)), 1), "\n")
cat("% con datos del hogar  :", round(100 * mean(!is.na(df25$HV005)), 1), "\n")

# 6. Guardar -------------------------------------------------------------------
write_csv(df25, paste0("data/processed/datos_", anio, ".csv"), na = "")
cat("\nGuardado: data/processed/datos_", anio, ".csv\n", sep = "")
