# _deis — DEIS deaths (MINSAL)

Everything is encrypted (`*.tar.xz.enc`). The notebooks use the `_tools/acc_data.R` loader and **never** read a plain CSV.

```r
source(here::here("_tools", "acc_data.R"))
mort21 <- nanoparquet::read_parquet(acc_data("_deis/DEFUNCIONES_DEIS_2012_2023_15plus.tar.xz.enc"))  # 2012-2023
mort24 <- acc_deis()   # 2024 onwards: newest version by the DDMMYYYY in the file name (prints file and md5)
```

`ACC_DEIS_VERSION=DDMMYYYY` in `~/.Renviron` pins an earlier version.

## 2012–2023: `DEFUNCIONES_DEIS_2012_2023_15plus.tar.xz.enc`

Built by `build_deis_2012_2023.R` from the official 1990–2023 CSV (`DEFUNCIONES_FUENTE_DEIS_1990_2023_CIFRAS_OFICIALES.csv`, md5 `54295f6503c93cf5e8025a4e20a391b0`, Latin-1, `;`, 27 columns), which is **not** in the repository.

Recipe (script header):

- years 2012–2023; `EDAD_TIPO == 1` (age in completed years); `EDAD_CANT >= 15`;
- columns: `year`, `gender`, `age`, `age_group` (1 = 15–29, 2 = 30–44, 3 = 45–59, 4 = 60+), `comuna`, `region`, `diag1`, `diag2`.

**Correction relative to the previous file** (`DEFUNCIONES_DEIS_12_23_15plus.parquet`, md5 `edb4f60848fb891aadf2c7d113f52aeb`, 1,330,807 rows): it lacked `EDAD_TIPO == 1`, so 1,826 infant deaths with age recorded in days (1,384), hours (440) or an unknown unit (2) entered as people aged 15+. Of those, 1,824 fell in ages 15–65 and 1,799 in 15–29.

Expected counts (the script stops if they do not match):

| | Before | Now |
|---|---|---|
| Rows 2012–2023 | 1,330,807 | **1,328,981** |
| 15–65 (`mort21`) | 369,854 | **368,030** |
| 15–29 | 32,752 | **30,953** (−5.5%) |

By year: 2012 96,209 · 2013 97,391 · 2014 99,476 · 2015 101,000 · 2016 101,787 · 2017 104,288 · 2018 104,752 · 2019 107,672 · 2020 124,569 · 2021 136,060 · 2022 135,274 · 2023 120,503.

md5 of the rebuilt parquet: `8652ad198a74a2242234862b382cf6db`.

## 2024 onwards: `DEFUNCIONES_FUENTE_DEIS_2024_2026_<DDMMYYYY>.tar.xz.enc`

The weekly DEIS CSV (Latin-1, `;`) packed as is. Current version `06102026`: 349,782 rows, last death 2026-10-03; 126,928 of them in 2024 (CSV md5 `636c10f44802f229a631218cf9ee2463`; zip md5 `1e452158fb46cb0c640583ca51c65cce`). Previous version `29092026`: 347,311 rows (CSV md5 `f87f9c02efbf8891fb45a946057bd8a1`).

Comparison across versions:

- **2024** was byte-for-byte identical in the 2026-06-09, 2026-09-15 and 2026-09-29 releases, and its rows are `identical()` in the 2026-10-06 release.
- **2025** was revised (~9,600 records) between June and September; unchanged between 2026-09-29 and 2026-10-06 (only 2026 grew: 93,917 → 96,388).

The `AÑO` header comes in Latin-1; `acc_deis()` returns it as valid UTF-8 (the old parquet had it in invalid UTF-8).
That is why `janitor::clean_names()` now gives **`ano`** instead of `a_o`: it is the only column that changes name; everything else is the same. With `ano`, the `mort24` built in `expand_pif` is `identical()` to the one built before from the old parquet (31,806 rows; same names and types).

### Format note: empty `diag2`

In `DEFUNCIONES_DEIS_2012_2023_15plus` an empty `diag2` is stored as `NA` (done by `build_deis_2012_2023.R`); the old parquet stored it as `""`. In the weekly 2024+ CSV it is still `""`. **No effect on current results:** `clean_icd10()` keeps both and `DIAG2_s6 %in% codes` is `FALSE` in either case. It would only matter to future code that filters with `!is.na(diag2)` or `diag2 != ""` on the combined 2012–2024 series.

## Weekly routine

1. Download `DEFUNCIONES_FUENTE_DEIS_2024_2026_<DDMMYYYY>.zip` from DEIS and leave it in `_deis/` (git ignores it).
2. From the repository root: `source("_tools/acc_data.R"); acc_deis_update()`. It prints deaths per year against the previous version; **if 2024 changes, the results change**.
3. Commit the new `.tar.xz.enc` and its `.md5.csv`.

## Documentation

`docs/Diccionario de Datos y Manual de Uso BBDD-COVID19 liberada.xlsx`: DEIS variable dictionary (sheet "Diccionario Dato Abierto").
