# _deis — Defunciones DEIS (MINSAL)

Todo cifrado (`*.tar.xz.enc`). Los notebooks usan el cargador `_tools/acc_data.R`; **nunca** leen un CSV en claro.

```r
source(here::here("_tools", "acc_data.R"))
mort21 <- nanoparquet::read_parquet(acc_data("_deis/DEFUNCIONES_DEIS_2012_2023_15plus.tar.xz.enc"))  # 2012-2023
mort24 <- acc_deis()   # 2024 en adelante: versión más reciente por la fecha DDMMYYYY del nombre (imprime archivo y md5)
```

`ACC_DEIS_VERSION=DDMMYYYY` en `~/.Renviron` fija una versión anterior.

## 2012–2023: `DEFUNCIONES_DEIS_2012_2023_15plus.tar.xz.enc`

Lo arma `build_deis_2012_2023.R` desde el CSV oficial 1990–2023 (`DEFUNCIONES_FUENTE_DEIS_1990_2023_CIFRAS_OFICIALES.csv`, md5 `54295f6503c93cf5e8025a4e20a391b0`, Latin-1, `;`, 27 columnas), que **no** está en el repo.

Receta (encabezado del script):

- años 2012–2023; `EDAD_TIPO == 1` (edad en años cumplidos); `EDAD_CANT >= 15`;
- columnas: `year`, `gender`, `age`, `age_group` (1 = 15–29, 2 = 30–44, 3 = 45–59, 4 = 60+), `comuna`, `region`, `diag1`, `diag2`.

**Corrección respecto del archivo anterior** (`DEFUNCIONES_DEIS_12_23_15plus.parquet`, md5 `edb4f60848fb891aadf2c7d113f52aeb`, 1.330.807 filas): faltaba `EDAD_TIPO == 1`, así que 1.826 defunciones de lactantes con edad en días (1.384), horas (440) o unidad desconocida (2) entraron como personas de 15+. De ellas 1.824 caían en 15–65 y 1.799 en 15–29.

Conteos esperados (el script se detiene si no calzan):

| | Antes | Ahora |
|---|---|---|
| Filas 2012–2023 | 1.330.807 | **1.328.981** |
| 15–65 (`mort21`) | 369.854 | **368.030** |
| 15–29 | 32.752 | **30.953** (−5,5%) |

Por año: 2012 96.209 · 2013 97.391 · 2014 99.476 · 2015 101.000 · 2016 101.787 · 2017 104.288 · 2018 104.752 · 2019 107.672 · 2020 124.569 · 2021 136.060 · 2022 135.274 · 2023 120.503.

md5 del parquet reconstruido: `8652ad198a74a2242234862b382cf6db`.

## 2024 en adelante: `DEFUNCIONES_FUENTE_DEIS_2024_2026_<DDMMYYYY>.tar.xz.enc`

El CSV semanal de DEIS (Latin-1, `;`) empaquetado tal cual. Versión actual `29092026`: 347.311 filas, última defunción 2026-09-26; 126.928 de 2024 (md5 del CSV `f87f9c02efbf8891fb45a946057bd8a1`; del zip `7f907247b68a9f77112af82c44e750cb`).

Comparación de versiones:

- **2024** fue idéntico byte a byte en las versiones del 09-06, 15-09 y 29-09 de 2026.
- **2025** se revisó (~9.600 registros) entre junio y septiembre.

El encabezado `AÑO` viene en Latin-1; `acc_deis()` lo entrega como UTF-8 válido (el parquet antiguo lo traía en UTF-8 inválido).
Por eso `janitor::clean_names()` da ahora **`ano`** y no `a_o`: es la única columna que cambia de nombre; el resto es igual. Con `ano`, el `mort24` de `expand_pif` es `identical()` al armado antes con el parquet viejo (31.806 filas; mismos nombres y tipos).

### Nota de formato: `diag2` vacío

En `DEFUNCIONES_DEIS_2012_2023_15plus` el `diag2` vacío está guardado como `NA` (lo hace `build_deis_2012_2023.R`); el parquet antiguo lo guardaba como `""`. En el CSV semanal 2024+ sigue siendo `""`. **Sin efecto en los resultados actuales:** `clean_icd10()` conserva ambos y `DIAG2_s6 %in% codes` es `FALSE` en los dos casos. Solo importaría a código futuro que filtre con `!is.na(diag2)` o `diag2 != ""` sobre la serie combinada 2012–2024.

## Rutina semanal

1. Descarga desde DEIS `DEFUNCIONES_FUENTE_DEIS_2024_2026_<DDMMYYYY>.zip` y déjalo en `_deis/` (git lo ignora).
2. Desde la raíz: `source("_tools/acc_data.R"); acc_deis_update()`. Imprime defunciones por año contra la versión anterior; **si 2024 cambia, los resultados cambian**.
3. Commitea el `.tar.xz.enc` nuevo y su `.md5.csv`.

## Documentación

`docs/Diccionario de Datos y Manual de Uso BBDD-COVID19 liberada.xlsx`: diccionario de variables de DEIS (hoja «Diccionario Dato Abierto»).
