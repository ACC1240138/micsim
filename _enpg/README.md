# _enpg — Encuesta Nacional de Drogas en Población General (ENPG)

Microdatos **cifrados** (`*.tar.xz.enc`, clave en `ACC_DATA_KEY`). Se leen solo con `acc_data()` (ver `README.md` de la raíz). Cada paquete trae un `*.md5.csv` con nombres, tamaños y md5.

```r
source(here::here("_tools", "acc_data.R"))
acc_data("_enpg/enpg.tar.xz.enc", "derived/ENPG_BINGE.RDS")   # un archivo del paquete
acc_data("_enpg/data_binge_sensitivity.rds.tar.xz.enc")       # paquete de un solo archivo
```

## Archivo canónico por ola (`_enpg/enpg.tar.xz.enc`, carpeta interna `enpg/`)

Filas × variables y md5 vienen de `__andres_control/eps_alcohol_outputs/enpg_wave_inventory.csv`.

| Ola | Archivo en el paquete | Filas × variables | md5 | Fuente |
|---|---|---|---|---|
| 2008 | `enpg2008.RDS` | 17.113 × 367 | d468b3650ea3491d311d83adaf8de50b | RDS local; procedencia por documentar |
| 2010 | `enpg2010.RDS` | 15.576 × 521 | 1dff2d05042804a48846c3128e84631a | RDS local; procedencia por documentar |
| 2012 | `Base de datos ENPG 2012 (PG).DTA.dta` | 17.154 × 451 | 178c9e8ed9264c1aba89c99ccb137eda | SENDA (base pública, Stata) |
| 2014 | `Base de datos ENPG 2014 (PG).DTA.dta` | 20.113 × 454 | 314c780019a90c44464ac991091d9913 | SENDA (base pública, Stata) |
| 2016 | `base ENPG 2016 publico general.dta` | 19.147 × 473 | 00a6db4c5be75432cd2a49c94eb65a2a | SENDA (base pública, Stata) |
| 2016 | `enpg16_factoresdeexpansion.dta` | — | ce64f075ab60dc690b27d3901ca49eee | factores de expansión 2016 (nombre que usa el script de diseño) |
| 2018 | `Base de datos ENPG 2018 (PG).DTA` | 19.427 × 499 | d69d7cd46f8473d24dd06327d639e88f | SENDA (base pública, Stata) |
| 2020 | `enpg2020.RDS` | 16.662 × 395 | 03b10d40b3c37e7f4417f3f18142d69c | RDS local; procedencia por documentar |
| 2022 | `BD - ENPG 2022 (Stata 16).dta` | 17.454 × 382 | 3300e94e433b385206a128c4f6a8ef3f | SENDA (base pública, Stata 16) |
| 2024 | `Base Publica ENPG 2024 (Stata 16).dta` | 18.668 × 402 | d2f6fd4e57b51c994cb6ede0396f6fb5 | SENDA (base pública, Stata 16) |

Notas:

- **2022:** existía además un `enpg2022.RDS`. Se comparó con el `.dta` (misma dimensión, mismos nombres, las 382 columnas con valores idénticos), por eso **no** se incluye.
- **2012:** existe una variante `.dta` con los mismos datos pero `region` y `codigo_comuna` sin tilde (`Base de datos ENPG 2012 (PG).dta`). Se excluyó; se usa la variante `.DTA.dta`.
- Excluidos por ser copias o derivados de otras versiones: los `enpg2012`–`enpg2018.RDS` de los repos FONDECYT y Mortalidad, `ENPG_FULL.RDS` (y su `.7z`), `Expansion16.RDS` y archivos de 2 bytes.

## Insumos derivados (`derived/` dentro del paquete)

| Archivo | md5 | Procedencia |
|---|---|---|
| `ENPG_BINGE.RDS` | 1ed65c4f6c45ee71bc1e76dbbbb268f0 | pipeline JRT (repo `Potentially-Avoidable-Injury-Mortality-in-Chile-`, ver `jrt/README.md`) |
| `enpg_design_waves_2012_2024_list.RDS` | 0b5e68e3a3f6a2dd827eecca8c665072 | caché de diseño que genera `__andres_control/build_enpg_design_waves_2012_2024_list.R` |
| `enpg_design_lookup_2022_2024_minimal.rds` | 241d2146acf96430f73c4c181bf63b16 | tabla de diseño 2022–2024. **Procedencia por documentar:** ningún notebook ni script vigente la lee; solo aparece en `expand_pif_pipeline_detailed.bpmn` |

`data_binge_sensitivity.rds` (paquete aparte, `_enpg/data_binge_sensitivity.rds.tar.xz.enc`) lo escribe `expand_pif.ipynb` y lo leen los notebooks de microsimulación.

Si se reconstruye la caché de diseño, hay que **volver a empaquetar** el paquete ENPG con `acc_pack()`.

## Documentación (`docs/<año>/`, sin cifrar)

Informes y cuestionarios públicos de SENDA. Faltan:

- informes y cuestionarios de **2008** y **2010**;
- cuestionario **2018** suelto: está en el Anexo III del informe (p. 305 en adelante) y en <https://www.senda.gob.cl/wp-content/uploads/2019/12/Cuestionario-ENPG-2018.pdf>;
- cuestionario **2020** suelto: está en el anexo del informe (pp. ~337–339).

## Notas (`notes/`)

Auditorías y radiografía de variables (`enpg_radiografia.md`/`.R`), auditorías de `tmp/eps_audit/enpg_*`, `codex_temp_audit_enpg/` e `diseno_historial/` (primera versión del diseño; ver su README).
