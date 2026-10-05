# jrt — reference material from the JRT team and other repositories

Inherited code and outputs that the notebooks use as a reference or for comparison. They are kept **unmodified** (except where noted below). Context: [01_mapa_material_jrt.md](01_mapa_material_jrt.md) (in Spanish).

## Source repositories (exact commit)

| Repository | Branch | Commit |
|---|---|---|
| `ACC1240138/Sex-and-age-differences-in-alcohol-attributable-mortality-in-Chile-between-2008-and-2022` | main | `91402ee5e4aa748ba3253859ad5dad31709cc95c` |
| `ACC1240138/FONDECYT-REGULAR-` | main | `af18ba0ca67d43e17655cdb0ef28744f819df774` |
| `ACC1240138/Potentially-Avoidable-Injury-Mortality-in-Chile-` | main (local copy `bc6359e`) | `bc6359e2796f4ffdb104060fc0dee3e524de09c9` |

Those repositories are **not** vendored here; only what is mapped into this repository.

**The only local modification with content** (in the `Sex-and-age-differences-…` repository, file `Paper mortality trends.R`): `exp(x * betas[1] - x^2 * betas[2])` → `exp(x * betas[1] + x^2 * betas[2])` (comment dated 2026-06-05). `Paper mortality trends.R` is not copied into this repository.

## Contents

| Folder | What is in it | Used by |
|---|---|---|
| `cancer_20260702/` | `Alcohol Attributable mortality (CANCER).txt` and `AAF CALCULATION CANCER-ACC_V2.R` (JRT reference); outputs `pipeline_vs_jrt_*` and `pipeline_cancer_aam_jrt_compatible_*` | `expand_pif.ipynb` (cancer AAF comparison) and `make_jrt_compatible_cancer_table_ge60.R` |
| `simulacion/` | `Alcohol Transitions_CALIB.R`, `Alcohol Transitions FINAL.R`, `MWE.R`, `patch_micSim.R` | `guion_reunion_ACC_2026-09-16_revision_critica.ipynb` |
| `elasticidad/` | the 5 harmonisation and elasticity-estimation scripts (`EPF ARMONIZATION.R`, `Elasticity 17_03.R`, `quaids_two_step_deaton.R`, `SENSITIVITY.R`, `Unit values deaton.R`) | `elasticidad_consolidado.ipynb` (provenance) |

The `.xlsx` of `Alcohol Attributable mortality (CANCER)` was left out: its content is exactly the same as the `.txt` (420 × 11, all columns identical).

## Warnings about `simulacion/`

The scripts are prototypes and **depend on the original project root**; they were not fixed:

- `MWE.R` runs `source("Simulacion/patch_micSim.R")` (three times). That path no longer exists; the file is at `jrt/simulacion/patch_micSim.R`.
- `Alcohol Transitions FINAL.R` runs `load("Alcohol Transitions FINAL.RData")`, a file that is **not** in the original folder nor here.
- `Alcohol Transitions_CALIB.R` fails to parse (prose text embedded in the code); the review notebook audits it for exactly that reason.
