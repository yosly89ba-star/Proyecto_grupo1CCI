# Proyecto_grupo1CCI

¿Qué factores individuales, maternos, del hogar y del entorno predicen la anemia en niños peruanos de 6 a 59 meses, y en qué medida el modelo entrenado con la ENDES 2024 mantiene su desempeño al validarse con la ENDES 2025?

**Autores:** Lourdes Barturen Sánchez, Ivonne Musayón Oblitas y Luis Rueda Milachay
**Curso:** Ciencia de Datos e IA Aplicada – Escuela de Posgrado, Universidad Peruana Unión

## Datos

### Fuente principal: ENDES 2024 y 2025

| Campo | Detalle |
|---|---|
| Fuente | Encuesta Demográfica y de Salud Familiar (ENDES), INEI |
| Portal | https://proyectos.inei.gob.pe/microdatos/ (Consulta por encuestas → ENDES → anual) |
| Años | 2024 (código 968) y 2025 (código 1036) |
| Módulos | 1638 Peso y talla – Anemia · 1629 Características del hogar · 1630 Características de la vivienda · 1634 Inmunización y salud |
| Diseño | Muestreo probabilístico, bietápico y equilibrado |

#### Archivos usados (7 por año)

| Archivo | Contenido | Llave | 2024 | 2025 |
|---|---|---|---|---|
| RECH6 | Niño < 5 años: hemoglobina, anemia, antropometría | HHID + HC0 | 20 290 | 19 298 |
| RECH5 | Mujer 12–49 años: anemia, IMC, embarazo | HHID + HA0 | 38 488 | 37 679 |
| REC44 | Puente entre el niño y su madre entrevistada | CASEID + HWIDX | 19 751 | 18 841 |
| REC43 | Diarrea y fiebre | CASEID + HIDX | 19 751 | 18 841 |
| REC95 | Hierro y control CRED | CASEID + IDX95 | 19 751 | 18 841 |
| RECH0 | Hogar: ponderación, área, altitud, UBIGEO | HHID | 37 390 | 37 331 |
| RECH23 | Vivienda: riqueza, agua, desagüe, combustible | HHID | 37 390 | 37 331 |

### Fuente complementaria: pobreza monetaria distrital

Mapa de pobreza monetaria provincial y distrital 2018 del INEI (1 874 distritos), obtenido de forma reproducible con el paquete de R [`perupobreza2018`](https://calderonsamuel.r-universe.dev/perupobreza2018). Se une a la ENDES por el código UBIGEO del hogar. Al ejecutar el reporte se guarda una copia en `data/raw/pobreza_distrital_2018.csv`.

**Los microdatos no se incluyen en este repositorio.** Son del INEI, no tienen una licencia abierta declarada y RECH0 contiene coordenadas de los conglomerados. Para reproducir el trabajo, descárgalos del portal y colócalos sin modificar en `data/raw/2024/` y `data/raw/2025/`.

Los diccionarios de variables del INEI están en `docs/diccionarios_inei/`, solo como referencia.

## Estructura

```
Proyecto_grupo1CCI/
├── R/
│   ├── 00_paquetes.R             # paquetes del proyecto
│   ├── union_2024.R              # une los 7 archivos de 2024 → datos_2024.csv
│   ├── union_2025.R              # une los 7 archivos de 2025 → datos_2025.csv
│   └── union_2024_2025.R         # apila los dos años → datos_2024_2025.csv
├── analysis/
│   ├── exploración inicial.qmd   # protocolo: limpieza, registro de decisiones y EDA
│   └── exploración inicial.html  # reporte renderizado
├── data/
│   ├── raw/                      # microdatos del INEI y pobreza distrital (no se versionan)
│   └── processed/                # bases generadas por el código (no se versionan)
├── docs/
│   ├── diccionario_datos.csv     # diccionario del dataset curado
│   └── diccionarios_inei/        # diccionarios PDF del INEI, 2024 y 2025
├── renv.lock                     # versiones exactas de R y paquetes
└── README.md
```

## Cómo reproducir

1. Clonar el repositorio y abrir `Proyecto_grupo1CCI.Rproj` en RStudio.
2. Ejecutar `renv::restore()` para instalar las versiones de `renv.lock`.
3. Descargar los 7 archivos de cada año y colocarlos en `data/raw/2024/` y `data/raw/2025/`.
4. Unir las bases, en orden:
   ```r
   source("R/union_2024.R")       # 20 290 filas, 48 columnas
   source("R/union_2025.R")       # 19 298 filas, 48 columnas
   source("R/union_2024_2025.R")  # 39 588 filas
   ```
5. Abrir `analysis/exploración inicial.qmd` y presionar **Render**. El reporte:
   - limpia los datos y documenta cada decisión (D01–D09),
   - une la pobreza distrital por UBIGEO,
   - verifica 5 reglas de validación,
   - guarda el dataset curado en `data/processed/anemia_curado.rds` (35 974 niños de 6 a 59 meses),
   - genera el análisis exploratorio de las hipótesis H1 a H7.

Entorno: R 4.5.2; paquetes readr, dplyr, tidyr, ggplot2, knitr y perupobreza2018 (versiones en `renv.lock`).

## Estado

- [x] Entorno reproducible con renv
- [x] Integración de los 7 archivos por año y unión de 2024 y 2025
- [x] Limpieza: valores centinela, faltantes, atípicos y duplicados
- [x] Integración de la pobreza distrital (por UBIGEO)
- [x] Diccionario de datos y registro de decisiones
- [x] Análisis exploratorio orientado a hipótesis (H1–H7)
- [ ] Modelado: regresión logística y bosque aleatorio (entrenamiento 2024, validación 2025)
- [ ] Interpretación y comunicación

Versión de cierre de la Unidad I: etiqueta `v1.0-unidad1`.

## Cita de los datos

Instituto Nacional de Estadística e Informática. (2020). *Mapa de pobreza monetaria provincial y distrital 2018*. INEI.

Instituto Nacional de Estadística e Informática. (2025). *Encuesta Demográfica y de Salud Familiar – ENDES 2024* [Conjunto de datos]. https://proyectos.inei.gob.pe/microdatos/

Instituto Nacional de Estadística e Informática. (2026). *Encuesta Demográfica y de Salud Familiar – ENDES 2025* [Conjunto de datos]. https://proyectos.inei.gob.pe/microdatos/