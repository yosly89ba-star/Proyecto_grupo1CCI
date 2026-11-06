# Proyecto_grupo1CCI
¿Qué factores individuales, maternos, del hogar y del entorno predicen la anemia en niños peruanos de 6 a 59 meses, y en qué medida el modelo entrenado con la ENDES 2024 mantiene su desempeño al validarse con la ENDES 2025?
## Datos

| Campo | Detalle |
|---|---|
| Fuente | Encuesta Demográfica y de Salud Familiar (ENDES), INEI |
| Portal | https://proyectos.inei.gob.pe/microdatos/ (Consulta por encuestas → ENDES → anual) |
| Años | 2024 (código 968) y 2025 (código 1036) |
| Módulos | 1638 Peso y talla – Anemia · 1629 Características del hogar · 1630 Características de la vivienda · 1634 Inmunización y salud |
| Diseño | Muestreo probabilístico, bietápico y equilibrado |

### Archivos usados (7 por año)

| Archivo | Contenido | Llave | 2024 | 2025 |
|---|---|---|---|---|
| RECH6 | Niño < 5 años: hemoglobina, anemia, antropometría | HHID + HC0 | 20 290 | 19 298 |
| RECH5 | Mujer 12–49 años: anemia, IMC, embarazo | HHID + HA0 | 38 488 | 37 679 |
| REC44 | Puente entre el niño y su madre entrevistada | CASEID + HWIDX | 19 751 | 18 841 |
| REC43 | Diarrea y fiebre | CASEID + HIDX | 19 751 | 18 841 |
| REC95 | Hierro y control CRED | CASEID + IDX95 | 19 751 | 18 841 |
| RECH0 | Hogar: ponderación, área, altitud, UBIGEO | HHID | 37 390 | 37 331 |
| RECH23 | Vivienda: riqueza, agua, desagüe, combustible | HHID | 37 390 | 37 331 |

**Los microdatos no se incluyen en este repositorio.** Son del INEI, no tienen una licencia
abierta declarada y RECH0 contiene coordenadas de los conglomerados. Para reproducir el
trabajo, descárgalos del portal y colócalos sin modificar en `data/raw/2024/` y `data/raw/2025/`.

Los diccionarios de variables del INEI están en `docs/diccionarios_inei/`, solo como referencia.

## Estructura

```
Proyecto_grupo1CCI/
├── R/
│   ├── 00_paquetes.R         # paquetes del proyecto
│   ├── union_2024.R          # une los 7 archivos de 2024 → datos_2024.csv
│   ├── union_2025.R          # une los 7 archivos de 2025 → datos_2025.csv
│   └── union_2024_2025.R     # apila los dos años → datos_2024_2025.csv
├── data/
│   ├── raw/                  # microdatos del INEI (no se versionan)
│   └── processed/            # bases generadas por los scripts (no se versionan)
├── docs/diccionarios_inei/   # diccionarios PDF del INEI, 2024 y 2025
├── decisiones.md             # registro de decisiones
├── renv.lock                 # versiones exactas de R y paquetes
└── README.md
```

## Cómo reproducir

1. Clonar el repositorio y abrir `Proyecto_grupo1CCI.Rproj` en RStudio.
2. Ejecutar `renv::restore()` para instalar las versiones de `renv.lock`.
3. Descargar los 7 archivos de cada año y colocarlos en `data/raw/2024/` y `data/raw/2025/`.
4. Ejecutar en orden:
   ```r
   source("R/union_2024.R")       # 20 290 filas, 48 columnas
   source("R/union_2025.R")       # 19 298 filas, 48 columnas
   source("R/union_2024_2025.R")  # 39 588 filas
   ```

Entorno: R 4.5.2; paquetes readr y dplyr (versiones en `renv.lock`).

## Estado

- [x] Entorno reproducible con renv
- [x] Integración de los 7 archivos por año y unión de 2024 y 2025
- [ ] Limpieza: faltantes, atípicos y duplicados
- [ ] Integración de la pobreza distrital (por UBIGEO)
- [ ] Modelado: regresión logística y bosque aleatorio (entrenamiento 2024, validación 2025)
- [ ] Interpretación y comunicación

## Cita de los datos

Instituto Nacional de Estadística e Informática. (2025). *Encuesta Demográfica y de Salud
Familiar – ENDES 2024* [Conjunto de datos]. https://proyectos.inei.gob.pe/microdatos/

Instituto Nacional de Estadística e Informática. (2026). *Encuesta Demográfica y de Salud
Familiar – ENDES 2025* [Conjunto de datos]. https://proyectos.inei.gob.pe/microdatos/