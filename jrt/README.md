# jrt — material de referencia del equipo (JRT) y de otros repos

Código y salidas heredadas que los notebooks usan como referencia o comparación. Se conservan **sin modificar** (salvo lo indicado abajo). Contexto: [01_mapa_material_jrt.md](01_mapa_material_jrt.md).

## Repositorios de origen (commit exacto)

| Repositorio | Rama | Commit |
|---|---|---|
| `ACC1240138/Sex-and-age-differences-in-alcohol-attributable-mortality-in-Chile-between-2008-and-2022` | main | `91402ee5e4aa748ba3253859ad5dad31709cc95c` |
| `ACC1240138/FONDECYT-REGULAR-` | main | `af18ba0ca67d43e17655cdb0ef28744f819df774` |
| `ACC1240138/Potentially-Avoidable-Injury-Mortality-in-Chile-` | main (copia local `bc6359e`) | `bc6359e2796f4ffdb104060fc0dee3e524de09c9` |

Esos repositorios **no** están vendorizados aquí; solo lo mapeado en este repo.

**Única modificación local con contenido** (en el repo `Sex-and-age-differences-…`, archivo `Paper mortality trends.R`): `exp(x * betas[1] - x^2 * betas[2])` → `exp(x * betas[1] + x^2 * betas[2])` (comentario del 2026-06-05). `Paper mortality trends.R` no se copia a este repo.

## Contenido

| Carpeta | Qué hay | Lo usa |
|---|---|---|
| `cancer_20260702/` | `Alcohol Attributable mortality (CANCER).txt` y `AAF CALCULATION CANCER-ACC_V2.R` (referencia JRT); salidas `pipeline_vs_jrt_*` y `pipeline_cancer_aam_jrt_compatible_*` | `expand_pif.ipynb` (comparación de AAF de cáncer) y `make_jrt_compatible_cancer_table_ge60.R` |
| `simulacion/` | `Alcohol Transitions_CALIB.R`, `Alcohol Transitions FINAL.R`, `MWE.R`, `patch_micSim.R` | `guion_reunion_ACC_2026-09-16_revision_critica.ipynb` |
| `elasticidad/` | los 5 scripts de armonización y estimación de elasticidades (`EPF ARMONIZATION.R`, `Elasticity 17_03.R`, `quaids_two_step_deaton.R`, `SENSITIVITY.R`, `Unit values deaton.R`) | `elasticidad_consolidado.ipynb` (procedencia) |

Se omitió el `.xlsx` de `Alcohol Attributable mortality (CANCER)`: tiene exactamente el mismo contenido que el `.txt` (420 × 11, todas las columnas idénticas).

## Advertencias sobre `simulacion/`

Los scripts son prototipos y **dependen de la raíz del proyecto original**, no se corrigieron:

- `MWE.R` hace `source("Simulacion/patch_micSim.R")` (tres veces). Esa ruta ya no existe; el archivo está en `jrt/simulacion/patch_micSim.R`.
- `Alcohol Transitions FINAL.R` hace `load("Alcohol Transitions FINAL.RData")`, archivo que **no** está en el original ni aquí.
- `Alcohol Transitions_CALIB.R` falla al parsear (texto en prosa incrustado); el guion lo audita justamente por eso.
