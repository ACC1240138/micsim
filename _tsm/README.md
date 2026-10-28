# _tsm — Termómetro de la Salud Mental ACHS-UC (TSM), rounds 7–11

**Encrypted** microdata in `tsm.tar.xz.enc` (five SPSS files, inner folder `tsm/`). Read them with `acc_data()`:

```r
source(here::here("_tools", "acc_data.R"))
tsm_root <- acc_data("_tsm/tsm.tar.xz.enc")   # decrypted tsm/ folder in tempdir()
haven::read_sav(file.path(tsm_root, "TSM Ronda 7.sav"))
```

`tsm.tar.xz.enc.md5.csv` lists every file with its size and md5 (the same as the originals; the v2 loader checks these md5 values).

## Rounds

Round dates are approximate fieldwork months (questionnaire covers for R7–R10; R11 from `notes/GUIA_LECTURA_BUNDLE_OUTPUTS.md`, no questionnaire available). Household rows list every member; the alcohol module is answered only by the panel respondent (`Entrevistado == 1`).

| File in the bundle | Round | Fieldwork | Household rows | Respondents | Note |
|---|---|---|---|---|---|
| `TSM Ronda 7.sav` | R7 | April 2023 | 7,684 | 3,012 | `e3b` (change since the pandemic) only in R7 and R8 |
| `TSM Ronda 8.sav` | R8 | December 2023 | 5,064 | 2,040 | |
| `TSM Ronda 9.sav` | R9 | April 2024 | 7,525 | 3,056 | |
| `TSM Ronda 10.sav` | R10 | November 2024 | 6,254 | 2,430 | three duplicated `IdPanel` in the household roster, none among respondents |
| `TSM Ronda 11.sav` | R11 | April 2025 (unverified) | 6,490 | 2,547 | questionnaire not available |

Key variables: `IdPanel` (longitudinal person key), `Fact_Exp` (round-specific cross-sectional expansion factor; no longitudinal weight, PSU or strata are released), `a2` sex, `a3` age, `b1`/`b4a`/`b4b` education (attending, highest level reached or current, last grade approved in that level), `e3a1`–`e3a3` alcohol frequency, typical quantity and 6+ drinks frequency (AUDIT-C items; no explicit recall window), `f15a`/`f15b` PHQ-2, `c1`–`c3` employment, `f1` housing, `IdRegion`.

**Provenance to be documented:** the source and terms of use of the SAV files were not recorded when they were copied from the working folder; the questionnaires are TSM instruments (ACHS-UC). Record the download or delivery source here before publication.

## Documents (`docs/`, plain)

Questionnaires R7–R10 (`Cuestionario R7.pdf` … `Cuestionario R10.pdf`): alcohol items on page 17, education on page 7, roster on pages 3–4.

## Notes (`notes/`)

- `CODEBOOK_TSM_SAV_variables.csv`, `diccionario_TSM_variables_relevantes.csv`: variable labels and value codes per round (metadata only).
- `hallazgos_TSM_factibilidad_markov.md`, `auditoria_TSM.md`, `TSM_pooled_metodo.md`, `hallazgos_TSM_pooled.md`, `TSM_correspondencia_Calvo_SENDA_propuesta.md`: Spanish feasibility, audit and method notes of the earlier Desktop analyses.
- `TSM_ENPG_v2_EN.md`, `TSM_ENPG_v2_findings.md`, `PLAN_TSM_v2.md`: narrative, findings and plan of version 2 (executed 2026-10-15 outside the repository).
- `v2_desktop_code/`: the R helpers of version 2 (`tsm_pooled_core.R` loader, history and weights; `tsm_v2_*.R`), kept as the ported source of the version 3 data layer. They read the SAV files from a working folder and are not run inside the repository.
- `v2_outputs/`: aggregate CSV results of version 2 (4,175 observed pairs from 1,934 people), the regression baseline for version 3.
- `GUIA_LECTURA_BUNDLE_OUTPUTS.md`, `MANIFEST.TXT`: round dates and the original file manifest.

## Notebook

`__andres_control/TSM_ENPG_v3_EN.ipynb`, built from `__andres_control/tsm_markov_data.R` and `tsm_markov_models.R` by `_tools/build_tsm_markov_notebook.py` (deleted 2026-10-27, in git history); aggregate outputs in `__andres_control/tsm_markov_outputs/`; plan in `__andres_control/tsm_v3_plan_2026-10-19.md`.
