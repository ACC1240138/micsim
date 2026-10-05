# _enpg — National Drug Survey of the General Population (ENPG)

**Encrypted** microdata (`*.tar.xz.enc`, key in `ACC_DATA_KEY`). They are read only with `acc_data()` (see the root `README.md`). Each bundle has a `*.md5.csv` with names, sizes and md5.

```r
source(here::here("_tools", "acc_data.R"))
acc_data("_enpg/enpg.tar.xz.enc", "derived/ENPG_BINGE.RDS")   # one file inside the bundle
acc_data("_enpg/data_binge_sensitivity.rds.tar.xz.enc")       # single-file bundle
```

## Canonical file per wave (`_enpg/enpg.tar.xz.enc`, inner folder `enpg/`)

Rows × variables and md5 come from `__andres_control/eps_alcohol_outputs/enpg_wave_inventory.csv`.

| Wave | File in the bundle | Rows × variables | md5 | Source |
|---|---|---|---|---|
| 2008 | `enpg2008.RDS` | 17,113 × 367 | d468b3650ea3491d311d83adaf8de50b | local RDS; provenance to be documented |
| 2010 | `enpg2010.RDS` | 15,576 × 521 | 1dff2d05042804a48846c3128e84631a | local RDS; provenance to be documented |
| 2012 | `Base de datos ENPG 2012 (PG).DTA.dta` | 17,154 × 451 | 178c9e8ed9264c1aba89c99ccb137eda | SENDA (public Stata file) |
| 2014 | `Base de datos ENPG 2014 (PG).DTA.dta` | 20,113 × 454 | 314c780019a90c44464ac991091d9913 | SENDA (public Stata file) |
| 2016 | `base ENPG 2016 publico general.dta` | 19,147 × 473 | 00a6db4c5be75432cd2a49c94eb65a2a | SENDA (public Stata file) |
| 2016 | `enpg16_factoresdeexpansion.dta` | — | ce64f075ab60dc690b27d3901ca49eee | 2016 expansion factors (the name the design script uses) |
| 2018 | `Base de datos ENPG 2018 (PG).DTA` | 19,427 × 499 | d69d7cd46f8473d24dd06327d639e88f | SENDA (public Stata file) |
| 2020 | `enpg2020.RDS` | 16,662 × 395 | 03b10d40b3c37e7f4417f3f18142d69c | local RDS; provenance to be documented |
| 2022 | `BD - ENPG 2022 (Stata 16).dta` | 17,454 × 382 | 3300e94e433b385206a128c4f6a8ef3f | SENDA (public Stata 16 file) |
| 2024 | `Base Publica ENPG 2024 (Stata 16).dta` | 18,668 × 402 | d2f6fd4e57b51c994cb6ede0396f6fb5 | SENDA (public Stata 16 file) |

Notes:

- **2022:** there was also an `enpg2022.RDS`. It was compared with the `.dta` (same dimensions, same names, all 382 columns with identical values), so it is **not** included.
- **2012:** a `.dta` variant exists with the same data but `region` and `codigo_comuna` without the accent (`Base de datos ENPG 2012 (PG).dta`). It was excluded; the `.DTA.dta` variant is used.
- Excluded as copies or derivatives of other versions: the `enpg2012`–`enpg2018.RDS` files from the FONDECYT and Mortalidad repositories, `ENPG_FULL.RDS` (and its `.7z`), `Expansion16.RDS`, and 2-byte files.

## Derived inputs (`derived/` inside the bundle)

| File | md5 | Provenance |
|---|---|---|
| `ENPG_BINGE.RDS` | 1ed65c4f6c45ee71bc1e76dbbbb268f0 | JRT pipeline (repository `Potentially-Avoidable-Injury-Mortality-in-Chile-`, see `jrt/README.md`) |
| `enpg_design_waves_2012_2024_list.RDS` | 0b5e68e3a3f6a2dd827eecca8c665072 | design cache produced by `__andres_control/build_enpg_design_waves_2012_2024_list.R` |
| `enpg_design_lookup_2022_2024_minimal.rds` | 241d2146acf96430f73c4c181bf63b16 | 2022–2024 design table. **Provenance to be documented:** no current notebook or script reads it; it only appears in `expand_pif_pipeline_detailed.bpmn` |

`data_binge_sensitivity.rds` (a separate bundle, `_enpg/data_binge_sensitivity.rds.tar.xz.enc`) is written by `expand_pif.ipynb` and read by the microsimulation notebooks.

If the design cache is rebuilt, the ENPG bundle must be **packed again** with `acc_pack()`.

## Documentation (`docs/<year>/`, plain)

Public SENDA reports and questionnaires. Missing:

- reports and questionnaires for **2008** and **2010**;
- the **2018** questionnaire as a separate file: it is in Annex III of the report (p. 305 onwards) and at <https://www.senda.gob.cl/wp-content/uploads/2019/12/Cuestionario-ENPG-2018.pdf>;
- the **2020** questionnaire as a separate file: it is in the annex of the report (pp. ~337–339).

## Notes (`notes/`)

Audits and a variable overview (`enpg_radiografia.md`/`.R`), audits from `tmp/eps_audit/enpg_*`, `codex_temp_audit_enpg/` and `diseno_historial/` (first version of the design; see its README).
